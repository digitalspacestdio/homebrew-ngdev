class DigitalspaceRedis < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.2"
  revision 110

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/110/digitalspace-redis"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "c2fb5cd4f4fe7dc1f84d7729cd507e07db61e5152c1a4fed37b1317245212c15"
    sha256 cellar: :any_skip_relocation, ventura:       "95fd5a9db21ffda8a02614ea420e63f53a8c8be3fb7c108d3016a09cf3f207fe"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "27a9f181678b5843fd68320515b24e24fff5748bd69dd94cb3e33368d885c705"
    sha256 cellar: :any_skip_relocation, aarch64_linux: "e9ed958287f51bff1b5fe5ea2356445f6fb49104467b7e867d1a00bf358ddc49"
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
