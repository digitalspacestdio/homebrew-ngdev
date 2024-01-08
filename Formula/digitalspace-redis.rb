class DigitalspaceRedis < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"

  depends_on 'redis'

  def redis_listen_address
    "127.0.0.1"
  end

  def redis_listen_port
    "6379"
  end
  def redis_wrapper_script
    <<~EOS
    #!/bin/sh
    exec #{Formula["redis"].opt_bin}/redis-server "$@"
    EOS
  rescue StandardError
      nil
  end


  def install
    (buildpath / "bin" / "digitalspace-redis-server").write(redis_wrapper_script)
    (buildpath / "bin" / "digitalspace-redis-server").chmod(0755)
    bin.install "bin/digitalspace-redis-server"
  end

  def post_install
    supervisor_config =<<~EOS
      [program:redis]
      command=#{Formula["redis"].opt_bin}/redis-server #{etc}/redis.conf
      directory=#{opt_prefix}
      stdout_logfile=#{var}/log/digitalspace-supervisor-redis.log
      stdout_logfile_maxbytes=1MB
      stderr_logfile=#{var}/log/digitalspace-supervisor-redis.err
      stderr_logfile_maxbytes=1MB
      user=#{ENV['USER']}
      autorestart=true
      stopasgroup=true
    EOS

    (etc/"digitalspace-supervisor.d").mkpath
    (etc/"digitalspace-supervisor.d"/"redis.ini").write(supervisor_config) unless (etc/"digitalspace-supervisor.d"/"redis.ini").exist?
  end
end