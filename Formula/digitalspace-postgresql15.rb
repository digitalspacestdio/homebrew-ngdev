class DigitalspacePostgresql15 < Formula
  desc "Object-relational database system"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v15.7/postgresql-15.7.tar.bz2"
  sha256 "a46fe49485ab6385e39dabbbb654f5d3049206f76cd695e224268729520998f7"
  license "PostgreSQL"
  revision 106

  livecheck do
    url "https://ftp.postgresql.org/pub/source/"
    regex(%r{href=["']?v?(15(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/digitalspacestdio/ngdev/digitalspace-postgresql15"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "318164bf7ca47106a4d9b1d4531ff0564018d81e1c43262960670f38c42e4948"
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

  def postgresql_base_dir
    opt_prefix
  end

  def postgresql_data_dir
    var / "lib" / "postgresql" / "15"
  end

  def postgresql_tmp_dir
    "/tmp"
  end

  def postgresql_log_dir
    var / "log" / "postgresql" / "15"
  end

  def postgresql_client_script
    <<~EOS
    #!/bin/sh
    exec #{bin}/psql -U postgres --host=#{postgresql_listen_address} --port=#{postgresql_listen_port} "$@"
    EOS
  rescue StandardError
      nil
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-ipcs",        # does not build on macOS
                          "--disable-ipcrm",       # does not build on macOS
                          "--disable-wall",        # already comes with macOS
                          "--enable-libuuid"       # conflicts with ossp-uuid
                          # "--disable-libsmartcols" # macOS already ships 'column'

    system "make", "install"

    # Remove binaries already shipped by macOS
    %w[cal col colcrt colrm getopt hexdump logger nologin look mesg more renice rev ul whereis].each do |prog|
      rm_f bin/prog
      rm_f sbin/prog
      rm_f man1/"#{prog}.1"
      rm_f man8/"#{prog}.8"
      rm_f share/"bash-completion/completions/#{prog}"
    end

    # # install completions only for installed programs
    # Pathname.glob("bash-completion/*") do |prog|
    #   if (bin/prog.basename).exist? || (sbin/prog.basename).exist?
    #     bash_completion.install prog
    #   end
    # end

    (buildpath / "bin" / "psql15").write(postgresql_client_script)
    (buildpath / "bin" / "psql15").chmod(0755)

    bin.install "bin/psql15"
  end

  test do
    out = shell_output("#{bin}/namei -lx /usr").split("\n")
    assert_equal ["f: /usr", "Drwxr-xr-x root wheel /", "drwxr-xr-x root wheel usr"], out
  end

  def post_install
    postgresql_log_dir.mkpath
    if !postgresql_data_dir.exist?
      postgresql_data_dir.mkpath
      system "#{bin}/initdb", "--username=postgres", "--locale=C", "-E", "UTF-8", postgresql_data_dir
    end

    supervisor_config =<<~EOS
      [program:postgresql15]
      command=#{bin}/postgres -D #{postgresql_data_dir}
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
    (etc/"digitalspace-supervisor.d"/"postgresql15.ini").write(supervisor_config) unless (etc/"digitalspace-supervisor.d"/"postgresql15.ini").exist?
  end

  service do
    run [Formula["postgresql@15"].opt_bin/"postgres", "-D", f.postgresql_data_dir]
    environment_variables LC_ALL: "C"
    keep_alive true
    require_root false
    log_path var/"log/digitalspace-service-postgresql15.log"
    error_log_path var/"log/digitalspace-service-postgresql15.log"
    working_dir HOMEBREW_PREFIX
  end
end