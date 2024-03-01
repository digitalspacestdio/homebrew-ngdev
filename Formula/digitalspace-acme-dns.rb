class DigitalspaceAcmeDns < Formula
  desc "Lightweight DNS forwarder and DHCP server"
  homepage "https://github.com/joohoi/acme-dns"
  url "https://github.com/digitalspacestdio/acme-dns/archive/refs/tags/1.0-fix.wildcard-dns.tar.gz"
  sha256 "474ce461d89786427c78b9408431c8c11ef54115dbf16ec5e9f455e160da91d6"
  version "1.0-fix.wildcard-dns"
  revision 4

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/nextgen-devenv/digitalspace-acme-dns"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "246106412665c97c03587f3ce17132674445fd9616b607e1ddca619053acb63e"
    sha256 cellar: :any_skip_relocation, sonoma:        "4d2400837c8ee2809c37213202426410f57386dc3b3222bfb5713d1872354a3a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "825f1b25c2941dcb140d4798d25873e04d22c8b28b8dd8132e5b3c59804ac189"
  end

  depends_on "go" => :build

  def start_script_macos
    <<~EOS
      #!/bin/bash
      set -e
      if [[ $(id -u ${USER}) != 0 ]]; then
        echo "You must run this script under the root user!"
        exit 1
      fi
      set -x
      mkdir -p /etc/resolver
      echo "nameserver 127.0.0.1" | tee /etc/resolver/dev.com
      echo "nameserver 127.0.0.1" | tee /etc/resolver/loc.com
      echo "nameserver 127.0.0.1" | tee /etc/resolver/dev.local
      cp #{HOMEBREW_PREFIX}/opt/digitalspace-acme-dns/homebrew.mxcl.digitalspace-dnsmasq.plist /Library/LaunchDaemons/homebrew.mxcl.digitalspace-acme-dns.plist
      launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.digitalspace-acme-dns.plist
      EOS
  rescue StandardError
      nil
  end

  def stop_script_macos
    <<~EOS
      #!/bin/bash
      set -e
      if [[ $(id -u ${USER}) != 0 ]]; then
        echo "You must run this script under the root user!"
        exit 1
      fi
      set -x
      if [[ -f /Library/LaunchDaemons/homebrew.mxcl.digitalspace-acme-dns.plist ]]; then
        launchctl unload -w /Library/LaunchDaemons/homebrew.mxcl.digitalspace-acme-dns.plist > /dev/null 2>&1
      fi
      rm /etc/resolver/dev.com
      rm /etc/resolver/loc.com
      rm /etc/resolver/dev.local
      chown -R  #{ENV['USER']} #{prefix}
      EOS
  rescue StandardError
      nil
  end

  def start_script_linux
      <<~EOS
        #!/bin/bash
        echo "not implemented"
        exit 1
        EOS
  rescue StandardError
      nil
  end

  def stop_script_linux
      <<~EOS
        #!/bin/bash
        echo "not implemented"
        exit 1
        EOS
  rescue StandardError
      nil
  end

  def acme_dns_config
    <<~EOS
    [general]
    # DNS interface. Note that systemd-resolved may reserve port 53 on 127.0.0.53
    # In this case acme-dns will error out and you will need to define the listening interface
    # for example: listen = "127.0.0.1:53"
    listen = "127.0.0.1:53"
    # protocol, "both", "both4", "both6", "udp", "udp4", "udp6" or "tcp", "tcp4", "tcp6"
    protocol = "both"
    # domain name to serve the requests off of
    domain = "auth.dev.local"
    # zone name server
    nsname = "auth.dev.local"
    # admin email address, where @ is substituted with .
    nsadmin = "admin.dev.local"
    # predefined records served in addition to the TXT
    records = [
        # domain pointing to the public IP of your acme-dns server 
        # "auth.dev.local. A 127.0.0.1",
        # specify that auth.example.org will resolve any *.auth.example.org records
        # "auth.example.org. NS auth.example.org.",
        "*.dev.local. A 127.0.0.1",
        "*.dev.com. A 127.0.0.1",
        "*.loc.com. A 127.0.0.1"
    ]
    # debug messages from CORS etc
    debug = false
    
    [database]
    # Database engine to use, sqlite3 or postgres
    engine = "sqlite3"
    # Connection string, filename for sqlite3 and postgres://$username:$password@$host/$db_name for postgres
    # Please note that the default Docker image uses path /var/lib/acme-dns/acme-dns.db for sqlite3
    connection = "#{var}/lib/digitalspace-acme-dns.db"
    # connection = "postgres://user:password@localhost/acmedns_db"
    
    [api]
    # listen ip eg. 127.0.0.1
    ip = "127.0.0.1"
    # disable registration endpoint
    disable_registration = false
    # listen port, eg. 443 for default HTTPS
    port = "5380"
    # possible values: "letsencrypt", "letsencryptstaging", "cert", "none"
    tls = "none"
    # only used if tls = "cert"
    # tls_cert_privkey = "/etc/tls/example.org/privkey.pem"
    # tls_cert_fullchain = "/etc/tls/example.org/fullchain.pem"
    # only used if tls = "letsencrypt"
    acme_cache_dir = "#{var}/lib/digitalspace-acme-dns-api-certs"
    # optional e-mail address to which Let's Encrypt will send expiration notices for the API's cert
    notification_email = ""
    # CORS AllowOrigins, wildcards can be used
    corsorigins = [
        "*"
    ]
    # use HTTP header to get the client ip
    use_header = false
    # header name to pull the ip address / list of ip addresses from
    header_name = "X-Forwarded-For"
    
    [logconfig]
    # logging level: "error", "warning", "info" or "debug"
    loglevel = "debug"
    # possible values: stdout, TODO file & integrations
    logtype = "stdout"
    # file path for logfile TODO
    # logfile = "#{var}/log/digitalspace-acme-dns.log"
    # format, either "json" or "text"
    logformat = "text"
    EOS
  rescue StandardError
      nil
  end

  def install
    system "go", "build"

    mv "acme-dns", "digitalspace-acme-dns"
    bin.install "digitalspace-acme-dns" 

    on_macos do
      (buildpath / "bin" / "digitalspace-acme-dns-start").write(start_script_macos)
      (buildpath / "bin" / "digitalspace-acme-dns-start").chmod(0755)
      bin.install "bin/digitalspace-acme-dns-start"

      (buildpath / "bin" / "digitalspace-acme-dns-stop").write(stop_script_macos)
      (buildpath / "bin" / "digitalspace-acme-dns-stop").chmod(0755)
      bin.install "bin/digitalspace-acme-dns-stop"
    end

    on_linux do
      (buildpath / "bin" / "digitalspace-acme-dns-start").write(start_script_linux)
      (buildpath / "bin" / "digitalspace-acme-dns-start").chmod(0755)
      bin.install "bin/digitalspace-acme-dns-start"

      (buildpath / "bin" / "digitalspace-acme-dns-stop").write(stop_script_linux)
      (buildpath / "bin" / "digitalspace-acme-dns-stop").chmod(0755)
      bin.install "bin/digitalspace-acme-dns-stop"
    end
  end

  def post_install
    (etc/"digitalspace-acme-dns.cfg").delete if (etc/"digitalspace-acme-dns.cfg").exist?
    (etc/"digitalspace-acme-dns.cfg").write(acme_dns_config)
  end

  service do
    run [opt_bin/"digitalspace-acme-dns", "-c", etc/"digitalspace-acme-dns.cfg"]
    keep_alive true
    require_root true
    working_dir HOMEBREW_PREFIX
    log_path var/"log/digitalspace-service-acme-dns.log"
    error_log_path var/"log/digitalspace-service-acme-dns-error.log"
  end

end