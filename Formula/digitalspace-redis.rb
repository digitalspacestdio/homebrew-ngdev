class DigitalspaceRedis < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.2"
  revision 111

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/111/digitalspace-redis"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "b33c8a8f6ca40bfb47fe6e70347de2cef01c17b1dbd5b6608191773f8e4b0bfe"
    sha256 cellar: :any_skip_relocation, ventura:       "4c85af1ffdb402b84227f98d60739ed6694b7e0674b582ffc1125664f69f0d66"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ed3e9a71c05f6f1ff67207c7bbe008ed3b96c9e7890c9104c1cf1a2d6c0c2f44"
  end

  depends_on 'redis'

  def service_wrapper_script
    <<~EOS
    #!/bin/sh
    if [ -f #{etc}/redis.override.conf ]; then
      exec #{Formula["redis"].opt_bin}/redis-server #{etc}/redis.override.conf "$@"
    fi

    exec #{Formula["redis"].opt_bin}/redis-server #{etc}/redis.conf "$@"
    EOS
  rescue StandardError
      nil
  end


  def install
    (buildpath / "bin" / "digitalspace-redis-server").write(service_wrapper_script)
    (buildpath / "bin" / "digitalspace-redis-server").chmod(0755)
    bin.install "bin/digitalspace-redis-server"
  end

  def post_install
    supervisor_config =<<~EOS
      [program:redis]
      command=#{Formula["redis"].opt_bin}/digitalspace-redis-server
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
    (etc/"digitalspace-supervisor.d"/"redis.ini").write(supervisor_config)
  end
end
