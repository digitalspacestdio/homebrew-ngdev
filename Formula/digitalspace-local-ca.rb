class DigitalspaceLocalCa < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"
  revision 109

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/109/digitalspace-local-ca"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "632a9805af384e88c720f7c76a9265cc4baf01dcbb7b6b7d2efef70b77e5c52a"
  end

  depends_on 'openssl'

  def ssl_ca_config
    <<~EOS
    # localCA.cnf file.
    #
    # Default configuration to use when one is not provided on the command line.
    #

    [ ca ]
    default_ca = local_ca

    #
    #
    # Default location of directories and files needed to generate certificates.
    #

    [ local_ca ]
    dir             = #{etc}/openssl/localCA
    certs           = $dir/certs
    crl_dir         = $dir/crl
    database        = $dir/index.txt
    new_certs_dir   = $dir/newcerts
    certificate     = $dir/root_ca.crt
    crlnumber       = $dir/crlnumber
    private_key     = $dir/private/cakey.pem
    serial = $dir/serial

    #
    #
    # Default expiration and encryption policies for certificates
    #

    default_crl_days = 365
    default_days = 398

    # sha1 is no longer recommended, we will be using sha256
    default_md = sha256

    #
    policy = local_ca_policy
    x509_extensions = local_ca_extensions

    #
    #
    # Copy extensions specified in the certificate request
    #
    copy_extensions = copy

    #
    #
    # Default policy to use when generating server certificates.
    # The following fields must be defined in the server certificate.
    #
    # DO NOT CHANGE "supplied" BELOW TO ANYTHING ELSE.
    # It is the correct content.
    #
    [ local_ca_policy ]
    commonName = supplied
    stateOrProvinceName = supplied
    countryName = supplied
    emailAddress = supplied
    organizationName = supplied
    organizationalUnitName = supplied

    #
    #
    # x509 extensions to use when generating server certificates
    #
    [ local_ca_extensions ]
    basicConstraints = CA:false

    #
    #
    # The default root certificate generation policy
    #
    [ req ]
    default_bits = 2048
    default_keyfile = #{etc}/openssl/localCA/private/cakey.pem


    #
    # sha1 is no longer recommended, we will be using sha256
    default_md = sha256
    #
    prompt = no
    distinguished_name = root_ca_distinguished_name
    x509_extensions = root_ca_extensions
    #
    #
    # Root Certificate Authority distinguished name
    #
    # DO CHANGE THE CONTENT OF THESE FIELDS TO MATCH
    # YOUR OWN SETTINGS!
    #

    [ root_ca_distinguished_name ]
    commonName = Localhost Root Certificate Authority
    stateOrProvinceName = NSW
    countryName = AU
    emailAddress = root@localhost
    organizationName = Localhost
    organizationalUnitName = Local Development Environment
    #
    [ root_ca_extensions ]
    basicConstraints = CA:true
    EOS
  rescue StandardError
      nil
  end

  def local_ca_crtgen_script
    <<~EOS
    #!/bin/bash
    set -e
    if [[ -z $1 ]]; then
      echo "Usage: $0 example.com"
      exit 1
    fi

    DOMAIN=$(echo $1 | sed -e 's/[^A-Za-z0-9._-]/_/g')

    if [[ $DOMAIN != $1 ]]; then
      echo "Invalid domain name"
      exit 1
    fi

    #if cat "#{etc}/openssl/localCA/index.txt" | grep "CN=${DOMAIN}"; then
    #  echo "Domain already exists"
    #  exit 1
    #fi

    tee #{etc}/openssl/localCA/${DOMAIN}.cnf << EOM
    [ req ]
    prompt = no
    distinguished_name = server_distinguished_name
    req_extensions = v3_req

    [ server_distinguished_name ]
    commonName = *.${DOMAIN}
    stateOrProvinceName = NSW
    countryName = AU
    emailAddress = root@${DOMAIN}
    organizationName = Local Inc
    organizationalUnitName = Local Development Environment

    [ v3_req ]
    basicConstraints = CA:FALSE
    keyUsage = nonRepudiation, digitalSignature, keyEncipherment
    subjectAltName = @alt_names

    [ alt_names ]
    DNS.0 = *.${DOMAIN}
    DNS.1 = ${DOMAIN}

    EOM

    export OPENSSL_CONF="#{etc}/openssl/localCA/${DOMAIN}.cnf"
    openssl req -newkey rsa:2048 -keyout #{etc}/openssl/localCA/private/${DOMAIN}_key.pem -keyform PEM -out #{etc}/openssl/localCA/${DOMAIN}_req.pem -outform PEM -nodes
    openssl rsa < #{etc}/openssl/localCA/private/${DOMAIN}_key.pem > #{etc}/openssl/localCA/private/${DOMAIN}.key

    export OPENSSL_CONF="#{etc}/openssl/localCA.cnf"
    openssl ca -batch -in #{etc}/openssl/localCA/${DOMAIN}_req.pem -out #{etc}/openssl/localCA/certs/${DOMAIN}.crt

    echo "Key file saved to #{etc}/openssl/localCA/private/${DOMAIN}.key"
    echo "Certificate saved to #{etc}/openssl/localCA/certs/${DOMAIN}.crt"
    EOS
  rescue StandardError
      nil
  end

  def local_ca_dir
    etc / "openssl" / "localCA"
  end

  def local_ca_config
    etc / "openssl" / "localCA.cnf"
  end

  def local_ca_init_script
    <<~EOS
    #!/bin/bash
    set -e
    export OPENSSL_CONF="#{local_ca_config}"
    rm -rf '#{local_ca_dir}'
    mkdir -p '#{local_ca_dir}/certs'
    mkdir -p '#{local_ca_dir}/newcerts'
    mkdir -p '#{local_ca_dir}/crl'
    mkdir -p '#{local_ca_dir}/private'

    echo "01" > #{local_ca_dir}/serial
    echo "unique_subject = no" > "#{local_ca_dir}/index.txt.attr"
    echo -n "" > "#{local_ca_dir}/index.txt"

    #{Formula["openssl"].opt_bin}/openssl req -x509 -sha256 -newkey rsa:2048 -nodes -days 1825 -outform PEM -out #{local_ca_dir}/root_ca.crt
    EOS
  rescue StandardError
      nil
  end

  def install
    (buildpath / "bin" / "local-ca-crtgen").write(local_ca_crtgen_script)
    (buildpath / "bin" / "local-ca-crtgen").chmod(0755)
    bin.install "bin/local-ca-crtgen"

    (buildpath / "bin" / "local-ca-init").write(local_ca_init_script)
    (buildpath / "bin" / "local-ca-init").chmod(0755)
    bin.install "bin/local-ca-init"
  end

  def post_install
    (local_ca_config).delete if (local_ca_config).exist?
    (local_ca_config).write(ssl_ca_config)
    
    ## Generating root CA
    system("#{opt_bin}/local-ca-init") unless (local_ca_dir/"root_ca.crt").exist?
  end
end
