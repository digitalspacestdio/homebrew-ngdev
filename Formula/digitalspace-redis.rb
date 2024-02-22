class DigitalspaceRedis < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.2"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/nextgen-devenv/digitalspace-redis"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "eb3d4233f609d021c7338787301fac7b81de9e5da3c9a1d3f4aaf283fd55dbde"
    sha256 cellar: :any_skip_relocation, sonoma:        "55dfb41ea8b19e2c8e02c65601d230ef70f9a558c8ee649349bb9800bb83c0b5"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "f816630b3e5d020e848d0b4da5e95eecf21f171fb9309407b096fb95f767bc8b"
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