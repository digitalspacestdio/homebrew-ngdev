class DigitalspaceMysql84 < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "8.4"
  revision 110

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/110/digitalspace-mysql84"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "26b16ff17ea11d02dc21f7e11705704487bcaa4b814300cceefe14a59ae47537"
    sha256 cellar: :any_skip_relocation, ventura:       "ba655e8739fde803be4110ea21d4e8c37ebb1c606cb7fd0a04f479c8904be9e0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7ca261f77052e4dd1941061a18c4fa13247e29bf8d157d581b9fbdc8c4dd2bc9"
    sha256 cellar: :any_skip_relocation, aarch64_linux: "8339236d8eaf87aabbd90018f9f26ba50976ed88f2a9b40913f382630bbb29c3"
  end

  def mysql_formula
    "digitalspace-mysql@8.4"
  end

  depends_on "mysql-client"
  depends_on "digitalspace-mysql@8.4"

  def mysql_listen_address
    ENV["HOMEBREW_NGDEV_MYSQL84_LISTEN_ADDRESS"] || "127.0.0.1"
  end

  def mysql_listen_port
    ENV["HOMEBREW_NGDEV_MYSQL84_LISTEN_PORT"] || "3306"
  end

  def mysql_base_dir
    Formula[mysql_formula].opt_prefix
  end

  def mysql_etc_dir
    etc / "digitalspace-mysql" / "8.4"
  end

  def mysql_data_dir
    var / "lib" / "digitalspace-mysql" / "8.4"
  end

  def mysql_tmp_dir
    "/tmp"
  end

  def mysql_log_dir
    var / "log" / "digitalspace-mysql" / "8.4"
  end

  def mysql_mydumper_script
    <<~EOS
    #!/bin/bash
    # set -x
    # set -e
    #
    # Usage: ./mydump.sh -h 127.0.0.1 -u root -p root mydb --skip-table-data-like "sales_%" --skip-table-data-like "quote%" | gzip > /tmp/databasename.sql.gz
    #
    POSITIONAL=()
    MYSQL_IGNORE_TABLE_DATA_LIKE=()
    MYSQL_IGNORE_TABLE_LIKE=()
    MYSQL_CLI=$(which #{Formula["digitalspace-mysql84"].opt_bin}/mysql84)
    MYSQLDUMP_CLI=$(which #{Formula["digitalspace-mysql84"].opt_bin}/mysqldump84)
    INCLUDE_SCHEMA=1
    INCLUDE_TRIGGERS=1
    INCLUDE_DATA=1
    DRY_RUN=0
    while [[ $# -gt 0 ]]
    do
        key="$1"
        case $key in
            -x|--debug)
            set -x
            shift # past argument
            ;;

            --dry|--dry-run)
            DRY_RUN=1
            shift # past argument
            ;;

            --dump-schema)
            INCLUDE_SCHEMA=2
            if [[ $INCLUDE_TRIGGERS == 1 ]]; then
                INCLUDE_TRIGGERS=0
            fi
            if [[ $INCLUDE_DATA == 1 ]]; then
                INCLUDE_DATA=0
            fi
            shift # past argument
            ;;

            --dump-triggers)
            INCLUDE_TRIGGERS=2
            if [[ $INCLUDE_SCHEMA == 1 ]]; then
                INCLUDE_SCHEMA=0
            fi
            if [[ $INCLUDE_DATA == 1 ]]; then
                INCLUDE_DATA=0
            fi
            shift # past argument
            ;;

            --dump-data)
            INCLUDE_DATA=2
            if [[ $INCLUDE_SCHEMA == 1 ]]; then
                INCLUDE_SCHEMA=0
            fi
            if [[ $INCLUDE_TRIGGERS == 1 ]]; then
                INCLUDE_TRIGGERS=0
            fi
            shift # past argument
            ;;

            --skip-table-data-like|--ignore-table-data-like)
            MYSQL_IGNORE_TABLE_DATA_LIKE+=(${2//_/\\\\_})
            shift # past argument
            shift # past value
            ;;

            --skip-table-like|--ignore-table-like)
            MYSQL_IGNORE_TABLE_LIKE+=(${2//_/\\\\_})
            shift # past argument
            shift # past value
            ;;

            -u|--user)
            MYSQL_USER="-u$2"
            shift # past argument
            shift # past value
            ;;

            -u*)
            MYSQL_USER="-u${key#*u}"
            shift # past argument
            ;;

            -p*)
            MYSQL_PASSWORD="${key#*p}"
            shift # past argument
            ;;

            -p|--password)
            >&2 echo "MySQL Password: "
            read -s MYSQL_PASSWORD
            shift # past argument
            ;;

            -h|--host)
            MYSQL_HOST="-h$2"
            shift # past argument
            shift # past value
            ;;
            -h*)
            MYSQL_HOST="-h${key#*h}"
            shift # past argument
            ;;

            -P|--port)
            MYSQL_PORT="-P$2"
            shift # past argument
            shift # past value
            ;;
            -P*)
            MYSQL_PORT="-P${key#*P}"
            shift # past argument
            ;;
            *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
        esac
    done

    if [[ ${#POSITIONAL[@]} -gt 0 ]]; then
        MYSQL_DB_NAME=${POSITIONAL[${#POSITIONAL[@]}-1]}
    fi

    if [[ -z "${MYSQL_DB_NAME}" ]]; then
        echo "Database was not specified!"
        exit 1
    fi

    export MYSQL_PWD=${MYSQL_PASSWORD-${MYSQL_PWD}}
    MYSQL_CMD="${MYSQL_CLI} -N ${MYSQL_HOST} ${MYSQL_PORT} ${MYSQL_USER} ${MYSQL_DB_NAME}"
    MYSQLDUMP_CMD="${MYSQLDUMP_CLI} -N ${MYSQL_HOST} ${MYSQL_PORT} ${MYSQL_USER}"
    MYSQLDUMP_CMD_EXTRA_ARGS="--no-tablespaces"

    if ${MYSQLDUMP_CMD} --help | grep set-gtid-purged > /dev/null; then
        MYSQLDUMP_CMD_EXTRA_ARGS="${MYSQLDUMP_CMD_EXTRA_ARGS} --set-gtid-purged=OFF"
    fi

    if ${MYSQLDUMP_CMD} --help | grep column-statistics > /dev/null; then
        MYSQLDUMP_CMD_EXTRA_ARGS="${MYSQLDUMP_CMD_EXTRA_ARGS} --column-statistics=0"
    fi

    IGNORE_TABLES=""
    for condition in "${MYSQL_IGNORE_TABLE_LIKE[@]}"
    do
        QUERY="show tables like '"${condition}"';"
        LCMD=${MYSQL_CMD}' -e "'${QUERY}'" | grep -v "^\\(sales_order_status\\|sales_order_status_label\\|sales_order_status_state\\)$"'
        LCMD_RES=$(bash -c "${LCMD}")
        IGNORE_TABLES=$(printf "${IGNORE_TABLES}\\n${LCMD_RES}")
    done

    IGNORE_TABLE_ARGS=$(echo "${IGNORE_TABLES}" | xargs -I{} printf '\\-\\-ignore-table '${MYSQL_DB_NAME}'.{} ')

    IGNORE_TABLES_DATA=""
    for condition in "${MYSQL_IGNORE_TABLE_DATA_LIKE[@]}"
    do
        QUERY="show tables like '"${condition}"';"
        LCMD=${MYSQL_CMD}' -e "'${QUERY}'" | grep -v "^\\(sales_order_status\\|sales_order_status_label\\|sales_order_status_state\\)$"'
        LCMD_RES=$(bash -c "${LCMD}")
        IGNORE_TABLES_DATA=$(printf "${IGNORE_TABLES_DATA}\\n${LCMD_RES}")
    done

    IGNORE_TABLE_DATA_ARGS=$(echo "${IGNORE_TABLES_DATA}" | xargs -I{} printf '\\-\\-ignore-table '${MYSQL_DB_NAME}'.{} ')

    if [[ $INCLUDE_SCHEMA > 0 ]]; then
        >&2 echo "Dumping schemas..."

        printf "\\n--\\n-- Dumping schemas\\n--\\n\\n"

        MYSQLCMD="${MYSQLDUMP_CMD} ${MYSQLDUMP_CMD_EXTRA_ARGS} --add-drop-table --no-data --skip-lock-tables --skip-triggers ${IGNORE_TABLE_ARGS} ${MYSQL_DB_NAME}"

        printf "\\n--\\n-- Executing: ${MYSQLCMD}\\n--\\n\\n"

        if [[ $DRY_RUN == 1 ]]; then
          >&2 echo ${MYSQLCMD}
        else
          bash -c "${MYSQLCMD}" | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\\*/\\*/' -e 's/\\sDEFINER[ ]*=[ ]*[^* ]*\\(\\s[A-Z]\\+\\s\\)/\\1/' || {
              exit 1
          }
        fi
    fi

    if [[ $INCLUDE_DATA > 0 ]]; then
        >&2 echo "Dumping data..."

        printf "\\n--\\n-- Dumping data\\n--\\n\\n"

        MYSQLCMD="${MYSQLDUMP_CMD} ${MYSQLDUMP_CMD_EXTRA_ARGS} --quick --max-allowed-packet=16M --disable-keys --hex-blob --skip-triggers --no-autocommit --no-create-info --insert-ignore --skip-lock-tables --single-transaction ${IGNORE_TABLE_ARGS} ${IGNORE_TABLE_DATA_ARGS} ${MYSQL_DB_NAME}"

        printf "\\n--\\n-- Execuring: ${MYSQLCMD}\\n--\\n\\n"

        if [[ $DRY_RUN == 1 ]]; then
          >&2 echo ${MYSQLCMD}
        else
          bash -c "${MYSQLCMD}" | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\\*/\\*/' -e 's/\\sDEFINER[ ]*=[ ]*[^* ]*\\(\\s[A-Z]\\+\\s\\)/\\1/' || {
              exit 1
          }
        fi
    fi

    if [[ $INCLUDE_TRIGGERS > 0 ]]; then
        >&2 echo "Dumping triggers and routines..."

        printf "\\n--\\n-- Dumping triggers, events and routines\\n--\\n\\n"

        MYSQLCMD="${MYSQLDUMP_CMD} ${MYSQLDUMP_CMD_EXTRA_ARGS} --no-data --skip-lock-tables --no-create-info --routines --triggers --events ${MYSQL_DB_NAME}"

        printf "\\n--\\n-- Executing: ${MYSQLCMD}\\n--\\n\\n"

        if [[ $DRY_RUN == 1 ]]; then
          >&2 echo ${MYSQLCMD}
        else
          bash -c "${MYSQLCMD}" | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\\*/\\*/' -e 's/\\sDEFINER[ ]*=[ ]*[^* ]*\\(\\s[A-Z]\\+\\s\\)/\\1/' || {
              exit 1
          }
        fi
    fi
    EOS
  rescue StandardError
    nil
  end

  def mysql_config
    <<~EOS
    [client]
    host               = #{mysql_listen_address}
    port               = #{mysql_listen_port}
    socket             = #{var}/run/mysqld84.sock

    [mysqld_safe]
    bind-address       = #{mysql_listen_address}
    pid-file           = #{var}/run/mysqld84.pid
    socket             = #{var}/run/mysqld84.sock
    port               = #{mysql_listen_port}
    nice               = 0

    [mysqld]
    disable_log_bin
    binlog_expire_logs_seconds = 3600
    explicit_defaults_for_timestamp = 1
    restrict_fk_on_non_standard_key = OFF

    user               = #{ENV['USER']}
    pid-file           = #{var}/run/mysqld84.pid
    socket             = #{var}/run/mysqld84.sock
    port               = #{mysql_listen_port}
    basedir            = #{Formula[mysql_formula].opt_prefix}
    datadir            = #{mysql_data_dir}
    tmpdir             = #{mysql_tmp_dir}
    lc-messages-dir    = #{mysql_base_dir}/share/mysql
    bind-address       = #{mysql_listen_address}

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

  def mysql_client_script
    <<~EOS
    #!/bin/sh
    exec #{Formula[mysql_formula].opt_bin}/mysql --defaults-file=#{mysql_etc_dir}/my.cnf --user root "$@"
    EOS
  rescue StandardError
      nil
  end

  def post_install_script
    <<~EOS
    #!/bin/sh
    set -x
    USED_BY_CONFIG=$(find "#{etc}/digitalspace-mysql/" -not -path "#{mysql_etc_dir}/*" -name my.cnf -exec grep port {} \\; 2>/dev/null | grep -o '[0-9]\\+' | sort | uniq);
    PORT=#{mysql_listen_port}
    while [ $PORT -le 65535 ] && ( echo "${USED_BY_CONFIG}" | grep -q $PORT || lsof -t -i tcp:$PORT ) > /dev/null
      do
        PORT=$((PORT+1));
      done;
    if [ "$OSTYPE" != "darwin"* ]; then
      sed -i -e 's~\\(port.*=\\).*~\\1 '$PORT'~g' #{mysql_etc_dir}/my.cnf
    else
      sed -i '' -e 's~\\(port.*=\\).*~\\1 '$PORT'~g' #{mysql_etc_dir}/my.cnf
    fi;
    EOS
  rescue StandardError
      nil
  end

  def install
    (buildpath / "bin" / "mydumper81").write(mysql_mydumper_script)
    (buildpath / "bin" / "mydumper81").chmod(0755)
    bin.install "bin/mydumper81"

    (buildpath / "bin" / "mysql84").write(mysql_client_script)
    (buildpath / "bin" / "mysql84").chmod(0755)
    bin.install "bin/mysql84"
  end

  def post_install
    mysql_etc_dir.mkpath
    mysql_log_dir.mkpath
    
    (opt_bin / "post_install_script").delete if (opt_bin / "post_install_script").exist?
    (opt_bin / "post_install_script").write(post_install_script)
    (opt_bin / "post_install_script").chmod(0755)

    if !(mysql_etc_dir / "my.cnf").exist?
      (mysql_etc_dir / "my.cnf").write(mysql_config)
      system("#{opt_bin}/post_install_script")
    end

    supervisor_config =<<~EOS
      [program:mysql84]
      command=#{Formula[mysql_formula].opt_bin}/mysqld --defaults-file=#{mysql_etc_dir}/my.cnf
      directory=#{opt_prefix}
      stdout_logfile=#{var}/log/digitalspace-supervisor-mysql84.log
      stdout_logfile_maxbytes=1MB
      stderr_logfile=#{var}/log/digitalspace-supervisor-mysql84.err
      stderr_logfile_maxbytes=1MB
      user=#{ENV['USER']}
      autorestart=true
      stopasgroup=true
    EOS

    (etc/"digitalspace-supervisor.d").mkpath
    (etc/"digitalspace-supervisor.d"/"mysql84.ini").delete if (etc/"digitalspace-supervisor.d"/"mysql84.ini").exist?
    (etc/"digitalspace-supervisor.d"/"mysql84.ini").write(supervisor_config) unless (etc/"digitalspace-supervisor.d"/"mysql84.ini").exist?

    if !mysql_data_dir.exist?
      mysql_data_dir.mkpath
      system("#{Formula[mysql_formula].opt_bin}/mysqld --defaults-file=#{mysql_etc_dir}/my.cnf --basedir=#{Formula[mysql_formula].opt_prefix} --datadir=#{mysql_data_dir} --lc-messages-dir=#{mysql_base_dir}/share/mysql --initialize-insecure")
    end
  end

  service do
    run ["#{Formula["digitalspace-mysql@8.4"].opt_bin}/mysqld", "--defaults-file=#{etc}/digitalspace-mysql/8.4/my.cnf"]
    working_dir HOMEBREW_PREFIX
    keep_alive true
    require_root false
    log_path var/"log/digitalspace-service-mysql84.log"
    error_log_path var/"log/digitalspace-service-mysql84.log"
  end
end
