class DigitalspaceRedis < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.2"
  revision 109

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/109/digitalspace-redis"
    sha256 cellar: :any_skip_relocation, ventura:      "5e4aa3cf415e028045709130fd793f6c3d08e8ac0dcef571f01b4651fab79247"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c13c2bc26cadde603d7e5ffaf8cb818f27927f63b01de422a26850ac4ea79ee0"
  end

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
