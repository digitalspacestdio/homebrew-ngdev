class DigitalspaceMailhog < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"
  revision 1

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/nextgen-devenv/digitalspace-mailhog"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "f62737ddacc0875e5da0d29d9d8a5060edaad1098d36bee2055cab0bfb4ae707"
    sha256 cellar: :any_skip_relocation, sonoma:        "a4190a614992a0a997355f85016ea37f93eb43c380fef62126dbae3b594ed40e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1b8790fb1aa1b957ac3381f3d03f75a431a9be4cf96b6d639a46b0b596cf3379"
  end

  depends_on "mailhog"
  depends_on "msmtp"

  def mailhog_msmtprc_config
    <<~EOS
    account default
    tls off
    tls_certcheck off
    auth off
    host 127.0.0.1
    port 1025
    from www-data@localhost
    EOS
  rescue StandardError
      nil
  end

  def mailhog_wrapper_script
    <<~EOS
    #!/bin/sh
    exec #{Formula["mailhog"].opt_bin}/MailHog "$@"
    EOS
  rescue StandardError
      nil
  end

  def install
    (buildpath / "bin" / "digitalspace-mailhog").write(mailhog_wrapper_script)
    (buildpath / "bin" / "digitalspace-mailhog").chmod(0755)

    bin.install "bin/digitalspace-mailhog"
  end

  def supervisor_config
    <<~EOS
      [program:mailhog]
      command=#{opt_bin}/digitalspace-mailhog -api-bind-addr 127.0.0.1:8025 -smtp-bind-addr 127.0.0.1:1025 -ui-bind-addr 127.0.0.1:8025
      directory=#{opt_prefix}
      stdout_logfile=#{var}/log/digitalspace-supervisor-mailhog.log
      stdout_logfile_maxbytes=1MB
      stderr_logfile=#{var}/log/digitalspace-supervisor-mailhog.err
      stderr_logfile_maxbytes=1MB
      autorestart=true
      stopasgroup=true
      EOS
  rescue StandardError
      nil
  end

  def post_install
    if !(etc / ".msmtprc").exist?
      (etc / ".msmtprc").write(mailhog_msmtprc_config)
      (etc / ".msmtprc").chmod(0644)
    end

    (etc/"digitalspace-supervisor.d").mkpath
    (etc/"digitalspace-supervisor.d"/"mailhog.ini").delete if (etc/"digitalspace-supervisor.d"/"mailhog.ini").exist?
    (etc/"digitalspace-supervisor.d"/"mailhog.ini").write(supervisor_config)
  end

  service do
    run [
      "#{opt_bin}/digitalspace-mailhog",
      "-api-bind-addr",
      "127.0.0.1:8025",
      "-smtp-bind-addr",
      "127.0.0.1:1025",
      "-ui-bind-addr",
      "127.0.0.1:8025",
    ]
    working_dir HOMEBREW_PREFIX
    keep_alive true
    log_path "#{var}/log/digitalspace-service-mailhog.log"
    error_log_path "#{var}/log/digitalspace-service-mailhog-error.log"
  end
end