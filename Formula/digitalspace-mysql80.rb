class DigitalspaceMysql80 < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "5.7"
  revision 107

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/107/digitalspace-mysql80"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "2e5f655d053cdbcfb9a5638d671d9d0f74ecafd3d0987956655569a6d5d6ec19"
    sha256 cellar: :any_skip_relocation, monterey:       "4c692e1b08f75b89ddf7c0e99d68937fe0eeaa9d27377c94dd31b3b034a157b4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "79858c65c80c8e4816814be5e554f36c2bfe46c7ef1a51e497876489713bf586"
  end

  depends_on 'digitalspace-mysql@8.0'

  def mysql_listen_address
    "127.0.0.1"
  end

  def mysql_listen_port
    "3306"
  end

  def mysql_base_dir
    opt_prefix
  end

  def mysql_etc_dir
    etc / "digitalspace-mysql" / "8.0"
  end

  def mysql_data_dir
    var / "lib" / "digitalspace-mysql" / "8.0"
  end

  def mysql_tmp_dir
    "/tmp"
  end

  def mysql_log_dir
    var / "log" / "digitalspace-mysql" / "8.0"
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
    MYSQL_CLI=$(which mysql)
    MYSQLDUMP_CLI=$(which mysqldump)
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
    port               = #{mysql_listen_port}
    socket             = #{var}/run/mysqld80.sock

    [mysqld_safe]
    bind-address       = 127.0.0.1
    pid-file           = #{var}/run/mysqld80.pid
    socket             = #{var}/run/mysqld80.sock
    port               = #{mysql_listen_port}
    nice               = 0

    [mysqld]
    disable_log_bin
    binlog_expire_logs_seconds = 3600
    default-authentication-plugin = mysql_native_password
    explicit_defaults_for_timestamp = 1

    user               = #{ENV['USER']}
    pid-file           = #{var}/run/mysqld80.pid
    socket             = #{var}/run/mysqld80.sock
    port               = #{mysql_listen_port}
    basedir            = #{mysql_base_dir}
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
    expire_logs_days      = 7

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
    exec #{Formula["digitalspace-mysql@8.0"].opt_bin}/mysql --defaults-file=#{etc}/mysql/8.0/my.cnf --host #{mysql_listen_address} --port #{mysql_listen_port} --user root "$@"
    EOS
  rescue StandardError
      nil
  end

  def install
    (buildpath / "bin" / "mydumper").write(mysql_mydumper_script)
    (buildpath / "bin" / "mydumper").chmod(0755)
    bin.install "bin/mydumper"

    (buildpath / "bin" / "mysql80").write(mysql_client_script)
    (buildpath / "bin" / "mysql80").chmod(0755)
    bin.install "bin/mysql80"
  end

  def post_install
    mysql_etc_dir.mkpath
    mysql_log_dir.mkpath
    (mysql_etc_dir / "my.cnf").write(mysql_config) unless (mysql_etc_dir / "my.cnf").exist?

    if !mysql_data_dir.exist?
      mysql_data_dir.mkpath
      system("#{Formula["digitalspace-mysql@8.0"].opt_bin}/mysqld --defaults-file=#{mysql_etc_dir}/my.cnf --basedir=#{mysql_base_dir} --datadir=#{mysql_data_dir} --lc-messages-dir=#{mysql_base_dir}/share/mysql --initialize-insecure")
    end

    supervisor_config =<<~EOS
      [program:mysql80]
      command=#{Formula["digitalspace-mysql@8.0"].opt_bin}/mysqld --defaults-file=#{etc}/mysql/8.0/my.cnf
      directory=#{opt_prefix}
      stdout_logfile=#{var}/log/digitalspace-supervisor-mysql80.log
      stdout_logfile_maxbytes=1MB
      stderr_logfile=#{var}/log/digitalspace-supervisor-mysql80.err
      stderr_logfile_maxbytes=1MB
      user=#{ENV['USER']}
      autorestart=true
      stopasgroup=true
    EOS

    (etc/"digitalspace-supervisor.d").mkpath
    (etc/"digitalspace-supervisor.d"/"mysql80.ini").delete if (etc/"digitalspace-supervisor.d"/"mysql80.ini").exist?
    (etc/"digitalspace-supervisor.d"/"mysql80.ini").write(supervisor_config) unless (etc/"digitalspace-supervisor.d"/"mysql80.ini").exist?
  end

  service do
    run ["#{Formula["digitalspace-mysql@8.0"].opt_bin}/mysqld", "--defaults-file=#{etc}/mysql/8.0/my.cnf"]
    working_dir HOMEBREW_PREFIX
    keep_alive true
    require_root false
    log_path var/"log/digitalspace-service-mysql80.log"
    error_log_path var/"log/digitalspace-service-mysql80.log"
  end
end
