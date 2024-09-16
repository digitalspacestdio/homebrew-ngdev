class DigitalspaceMysqlAT57 < Formula
  desc "Open source relational database management system"
  homepage "https://dev.mysql.com/doc/refman/5.7/en/"
  url "https://cdn.mysql.com/Downloads/MySQL-5.7/mysql-boost-5.7.44.tar.gz"
  sha256 "b8fe262c4679cb7bbc379a3f1addc723844db168628ce2acf78d33906849e491"
  license "GPL-2.0-only"
  revision 107

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/107/digitalspace-mysql@5.7"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "424315e0d87efd7a78868640ac5cfe12d237680730ebd5f1764a91d471895cbd"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "libevent"
  depends_on "lz4"
  depends_on "openssl@1.1"
  depends_on "protobuf"

  uses_from_macos "curl"
  uses_from_macos "cyrus-sasl"
  uses_from_macos "libedit"

  on_linux do
    depends_on "pkg-config" => :build
    depends_on "libtirpc"
  end

  def mysql_listen_address
    "127.0.0.1"
  end

  def mysql_listen_port
    "3357"
  end

  def mysql_base_dir
    opt_prefix
  end

  def mysql_data_dir
    var / "lib" / "digitalspace-mysql" / "5.7"
  end

  def mysql_etc_dir
    etc / "digitalspace-mysql" / "5.7"
  end

  def mysql_log_dir
    var / "log" / "digitalspace-mysql" / "5.7"
  end

  def mysql_tmp_dir
    "/tmp"
  end

  def mysql_config
    <<~EOS
    [client]
    port               = #{mysql_listen_port}
    socket             = #{var}/run/mysqld57.sock

    [mysqld_safe]
    bind-address       = 127.0.0.1
    pid-file           = #{var}/run/mysqld57.pid
    socket             = #{var}/run/mysqld57.sock
    port               = #{mysql_listen_port}
    nice               = 0

    [mysqld]
    default-authentication-plugin = mysql_native_password
    user               = #{ENV['USER']}
    pid-file           = #{var}/run/mysqld57.pid
    socket             = #{var}/run/mysqld57.sock
    port               = #{mysql_listen_port}
    basedir            = #{mysql_base_dir}
    datadir            = #{mysql_data_dir}
    tmpdir             = #{mysql_tmp_dir}
    lc-messages-dir    = #{mysql_base_dir}/share/mysql
    bind-address       = #{mysql_listen_address}
    explicit_defaults_for_timestamp = 1

    secure_file_priv   = #{mysql_tmp_dir}
    general_log_file   = #{mysql_log_dir}/query.log
    general_log        = 0

    log_bin_trust_function_creators = 1

    # * Fine Tuning
    max_allowed_packet    = 512M
    thread_stack          = 192K
    thread_cache_size     = 8
    interactive_timeout   = 300
    wait_timeout          = 900
    sort_buffer_size      = 16M
    read_rnd_buffer_size  = 16M
    read_buffer_size      = 16M
    join_buffer_size      = 16M
    key_buffer_size       = 256M
    tmp_table_size        = 256M
    max_heap_table_size   = 256M
    log_error             = #{mysql_log_dir}/error.log

    innodb_doublewrite              = 0
    innodb_file_per_table           = 1
    innodb_thread_concurrency       = 8
    innodb_lock_wait_timeout        = 300
    innodb_flush_method             = O_DSYNC
    innodb_log_files_in_group       = 2
    innodb_log_file_size            = 1G # if changing, stop database, remove old log files, then start!
    innodb_log_buffer_size          = 64M
    innodb_flush_log_at_trx_commit  = 2
    innodb_buffer_pool_size         = 2G
    innodb_buffer_pool_instances    = 8

    lower_case_table_names=2
    table_open_cache=250

    [mysqldump]
    quick
    quote-names
    max_allowed_packet = 16M
    EOS
  rescue StandardError
      nil
  end

  # Fixes loading of VERSION file, backported from mysql/mysql-server@51675dd
  patch :DATA

  def install
    if OS.linux?
      # Fix libmysqlgcs.a(gcs_logging.cc.o): relocation R_X86_64_32
      # against `_ZN17Gcs_debug_options12m_debug_noneB5cxx11E' can not be used when making
      # a shared object; recompile with -fPIC
      ENV.append_to_cflags "-fPIC"
    end

    # Fixes loading of VERSION file; used in conjunction with patch
    File.rename "VERSION", "MYSQL_VERSION"

    # -DINSTALL_* are relative to `CMAKE_INSTALL_PREFIX` (`prefix`)
    args = %W[
      -DCOMPILATION_COMMENT=Homebrew
      -DDEFAULT_CHARSET=utf8
      -DDEFAULT_COLLATION=utf8_general_ci
      -DINSTALL_DOCDIR=share/doc/#{name}
      -DINSTALL_INCLUDEDIR=include/mysql
      -DINSTALL_INFODIR=share/info
      -DINSTALL_MANDIR=share/man
      -DINSTALL_MYSQLSHAREDIR=share/mysql
      -DINSTALL_PLUGINDIR=lib/plugin
      -DMYSQL_DATADIR=#{mysql_data_dir}
      -DSYSCONFDIR=#{mysql_etc_dir}
      -DWITH_BOOST=boost
      -DWITH_EDITLINE=system
      -DWITH_SSL=yes
      -DWITH_NUMA=OFF
      -DWITH_UNIT_TESTS=OFF
      -DWITH_EMBEDDED_SERVER=ON
    ]

    args << if OS.mac?
      "-DWITH_INNODB_MEMCACHED=ON" # InnoDB memcached plugin build fails on Linux
    else
      "-DENABLE_DTRACE=0"
    end

    system "cmake", ".", *std_cmake_args, *args
    system "make"
    system "make", "install"

    # (prefix/"mysql-test").cd do
    #   system "./mysql-test-run.pl", "status", "--vardir=#{Dir.mktmpdir}"
    # end

    # Remove the tests directory
    # rm_r(prefix/"mysql-test")

    # Don't create databases inside of the prefix!
    # See: https://github.com/Homebrew/homebrew/issues/4975
    # rm_r(prefix/"data")

    # Fix up the control script and link into bin.
    inreplace "#{prefix}/support-files/mysql.server",
              /^(PATH=".*)(")/,
              "\\1:#{HOMEBREW_PREFIX}/bin\\2"
    # bin.install_symlink prefix/"support-files/mysql.server"

    # Install my.cnf that binds to 127.0.0.1 by default
    # (buildpath/"my.cnf").write <<~EOS
    #   # Default Homebrew MySQL server config
    #   [mysqld]
    #   # Only allow connections from localhost
    #   bind-address = 127.0.0.1
    # EOS

    (buildpath/"my.cnf").write(mysql_config)
    
    # etc.install "my.cnf"
  end

  # def post_install
  #   # Make sure the var/mysql directory exists
  #   (var/"mysql").mkpath

  #   # Don't initialize database, it clashes when testing other MySQL-like implementations.
  #   return if ENV["HOMEBREW_GITHUB_ACTIONS"]

  #   unless (mysql_data_dir/"mysql/general_log.CSM").exist?
  #     ENV["TMPDIR"] = nil
  #     system bin/"mysqld", "--initialize-insecure", "--user=#{ENV["USER"]}",
  #       "--basedir=#{prefix}", "--datadir=#{mysql_data_dir}", "--tmpdir=/tmp"
  #   end
  # end

  def caveats
    s = <<~EOS
      We've installed your MySQL database without a root password. To secure it run:
          mysql_secure_installation

      MySQL is configured to only allow connections from localhost by default

      To connect run:
          mysql -uroot
    EOS
    if (my_cnf = ["/etc/my.cnf", "/etc/mysql/my.cnf"].find { |x| File.exist? x })
      s += <<~EOS

        A "#{my_cnf}" from another install may interfere with a Homebrew-built
        server starting up correctly.
      EOS
    end
    s
  end

  # service do
  #   run [opt_bin/"mysqld_safe", "--datadir=#{mysql_data_dir}"]
  #   keep_alive true
  #   working_dir var/"mysql"
  # end

  test do
    (testpath/"mysql").mkpath
    (testpath/"tmp").mkpath
    system bin/"mysqld", "--no-defaults", "--initialize-insecure", "--user=#{ENV["USER"]}",
      "--basedir=#{prefix}", "--datadir=#{testpath}/mysql", "--tmpdir=#{testpath}/tmp"
    port = free_port
    fork do
      system bin/"mysqld", "--no-defaults", "--user=#{ENV["USER"]}",
        "--datadir=#{testpath}/mysql", "--port=#{port}", "--tmpdir=#{testpath}/tmp"
    end
    sleep 5
    assert_match "information_schema",
      shell_output("#{bin}/mysql --port=#{port} --user=root --password= --execute='show databases;'")
    system bin/"mysqladmin", "--port=#{port}", "--user=root", "--password=", "shutdown"
  end
end

__END__
diff --git a/cmake/mysql_version.cmake b/cmake/mysql_version.cmake
index 43d731e..3031258 100644
--- a/cmake/mysql_version.cmake
+++ b/cmake/mysql_version.cmake
@@ -31,7 +31,7 @@ SET(DOT_FRM_VERSION "6")
 
 # Generate "something" to trigger cmake rerun when VERSION changes
 CONFIGURE_FILE(
-  ${CMAKE_SOURCE_DIR}/VERSION
+  ${CMAKE_SOURCE_DIR}/MYSQL_VERSION
   ${CMAKE_BINARY_DIR}/VERSION.dep
 )
 
@@ -39,7 +39,7 @@ CONFIGURE_FILE(
 
 MACRO(MYSQL_GET_CONFIG_VALUE keyword var)
  IF(NOT ${var})
-   FILE (STRINGS ${CMAKE_SOURCE_DIR}/VERSION str REGEX "^[ ]*${keyword}=")
+   FILE (STRINGS ${CMAKE_SOURCE_DIR}/MYSQL_VERSION str REGEX "^[ ]*${keyword}=")
    IF(str)
      STRING(REPLACE "${keyword}=" "" str ${str})
      STRING(REGEX REPLACE  "[ ].*" ""  str "${str}")