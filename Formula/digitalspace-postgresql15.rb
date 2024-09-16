class DigitalspacePostgresql15 < Formula
  desc "Object-relational database system"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v15.8/postgresql-15.8.tar.bz2"
  sha256 "4403515f9a69eeb3efebc98f30b8c696122bfdf895e92b3b23f5b8e769edcb6a"
  license "PostgreSQL"
  revision 107

  livecheck do
    url "https://ftp.postgresql.org/pub/source/"
    regex(%r{href=["']?v?(15(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/107/digitalspace-postgresql15"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "e3d2f480711f163a059a713232af302a437b0c8d1bd18eb36503f3109229f84e"
    sha256 cellar: :any_skip_relocation, monterey:       "808a74152677c9c70193bf1a7f619a48d2b3d7a32b4c4dd2f5560aa58273a3b5"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "d16946e58f97731839082be0054e0e07b28d9e05204c66748fc83318fadfa75e"
  end

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "icu4c"

  # GSSAPI provided by Kerberos.framework crashes when forked.
  # See https://github.com/Homebrew/homebrew-core/issues/47494.
  depends_on "krb5"

  depends_on "lz4"
  depends_on "openssl@3"
  depends_on "readline"
  depends_on "zstd"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"
  uses_from_macos "openldap"
  uses_from_macos "perl"
  uses_from_macos "zlib"

  on_linux do
    depends_on "linux-pam"
    depends_on "util-linux"
  end

  def postgresql_listen_address
    "127.0.0.1"
  end

  def postgresql_listen_port
    "5432"
  end

  def postgresql_log_dir
    var / "log" / "digitalspace-postgresql" / "15"
  end

  def postgresql_client_script
    <<~EOS
    #!/bin/sh
    exec #{bin}/psql -U $USER -d $USER --host=#{postgresql_listen_address} --port=#{postgresql_listen_port} "$@"
    EOS
  rescue StandardError
      nil
  end

  def install
    ENV.delete "PKG_CONFIG_LIBDIR"
    ENV.prepend "LDFLAGS", "-L#{Formula["openssl@3"].opt_lib} -L#{Formula["readline"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl@3"].opt_include} -I#{Formula["readline"].opt_include}"

    # Fix 'libintl.h' file not found for extensions
    ENV.prepend "LDFLAGS", "-L#{Formula["gettext"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["gettext"].opt_include}"

    on_linux do
      ENV.prepend "LDFLAGS", "-L#{Formula["util-linux"].opt_lib}"
      ENV.prepend "CPPFLAGS", "-I#{Formula["util-linux"].opt_include}"
    end    

    args = std_configure_args + %W[
      --datadir=#{opt_pkgshare}
      --libdir=#{opt_lib}
      --includedir=#{opt_include}
      --sysconfdir=#{etc}
      --docdir=#{doc}
      --enable-nls
      --enable-thread-safety
      --with-gssapi
      --with-icu
      --with-ldap
      --with-libxml
      --with-libxslt
      --with-lz4
      --with-zstd
      --with-openssl
      --with-pam
      --with-perl
      --with-uuid=e2fs
      --with-extra-version=\ (#{tap.user})
    ]
    if OS.mac?
      args += %w[
        --with-bonjour
        --with-tcl
      ]
    end

    # PostgreSQL by default uses xcodebuild internally to determine this,
    # which does not work on CLT-only installs.
    args << "PG_SYSROOT=#{MacOS.sdk_path}" if OS.mac? && MacOS.sdk_root_needed?

    system "./configure", *args

    # Work around busted path magic in Makefile.global.in. This can't be specified
    # in ./configure, but needs to be set here otherwise install prefixes containing
    # the string "postgres" will get an incorrect pkglibdir.
    # See https://github.com/Homebrew/homebrew-core/issues/62930#issuecomment-709411789
    system "make", "pkglibdir=#{opt_lib}/postgresql",
                   "pkgincludedir=#{opt_include}/postgresql",
                   "includedir_server=#{opt_include}/postgresql/server"
    system "make", "install-world", "datadir=#{pkgshare}",
                                    "libdir=#{lib}",
                                    "pkglibdir=#{lib}/postgresql",
                                    "includedir=#{include}",
                                    "pkgincludedir=#{include}/postgresql",
                                    "includedir_server=#{include}/postgresql/server",
                                    "includedir_internal=#{include}/postgresql/internal"

    if OS.linux?
      inreplace lib/"postgresql/pgxs/src/Makefile.global",
                "LD = #{HOMEBREW_PREFIX}/Homebrew/Library/Homebrew/shims/linux/super/ld",
                "LD = #{HOMEBREW_PREFIX}/bin/ld"
    end

    (buildpath / "bin" / "psql15").write(postgresql_client_script)
    (buildpath / "bin" / "psql15").chmod(0755)

    bin.install "bin/psql15"
  end

  def post_install
    (var/"log").mkpath
    postgresql_datadir.mkpath

    # Don't initialize database, it clashes when testing other PostgreSQL versions.
    return if ENV["HOMEBREW_GITHUB_ACTIONS"]

    system bin/"initdb", -U, ENV['USER'], -d, ENV['USER'], "--locale=C", "-E", "UTF-8", postgresql_datadir unless pg_version_exists?

    supervisor_config =<<~EOS
      [program:postgresql15]
      command=#{bin}/postgres -D #{postgresql_datadir}
      environment=LC_ALL=C
      directory=#{opt_prefix}
      stdout_logfile=#{var}/log/digitalspace-supervisor-postgresql15.log
      stdout_logfile_maxbytes=1MB
      stderr_logfile=#{var}/log/digitalspace-supervisor-postgresql15.err
      stderr_logfile_maxbytes=1MB
      user=#{ENV['USER']}
      autorestart=true
      stopasgroup=true
    EOS

    (etc/"digitalspace-supervisor.d").mkpath
    (etc/"digitalspace-supervisor.d"/"postgresql15.ini").delete if (etc/"digitalspace-supervisor.d"/"postgresql15.ini").exist?
    (etc/"digitalspace-supervisor.d"/"postgresql15.ini").write(supervisor_config)

    (buildpath / "bin" / "psql15").write(postgresql_client_script)
    (buildpath / "bin" / "psql15").chmod(0755)
  end

  def postgresql_datadir
    var / "lib" / "digitalspace-postgresql" / "15"
  end

  def postgresql_log_path
    var/"log/#{name}.log"
  end

  def pg_version_exists?
    (postgresql_datadir/"PG_VERSION").exist?
  end

  def caveats
    <<~EOS
      This formula has created a default database cluster with:
        initdb --locale=C -E UTF-8 #{postgresql_datadir}
      For more details, read:
        https://www.postgresql.org/docs/#{version.major}/app-initdb.html
    EOS
  end

  service do
    run [opt_bin/"postgres", "-D", f.postgresql_datadir]
    environment_variables LC_ALL: "C"
    keep_alive true
    require_root false
    log_path var/"log/digitalspace-service-postgresql15.log"
    error_log_path var/"log/digitalspace-service-postgresql15.log"
    working_dir HOMEBREW_PREFIX
  end
end
