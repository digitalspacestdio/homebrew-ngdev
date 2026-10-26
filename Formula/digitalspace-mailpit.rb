class DigitalspaceMailpit < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"
  revision 111

  depends_on "mailpit"
  depends_on "msmtp"

  conflicts_with "digitalspace-mailhog", because: "both listen on ports 1025 and 8025"

  def mailpit_msmtprc_config
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

  def mailpit_wrapper_script
    <<~EOS
    #!/bin/sh
    exec #{Formula["mailpit"].opt_bin}/mailpit "$@"
    EOS
  rescue StandardError
      nil
  end

  def install
    (buildpath / "bin" / "digitalspace-mailpit").write(mailpit_wrapper_script)
    (buildpath / "bin" / "digitalspace-mailpit").chmod(0755)

    bin.install "bin/digitalspace-mailpit"
  end

  def supervisor_config
    <<~EOS
      [program:mailpit]
      command=#{opt_bin}/digitalspace-mailpit --listen 127.0.0.1:8025 --smtp 127.0.0.1:1025
      directory=#{opt_prefix}
      stdout_logfile=#{var}/log/digitalspace-supervisor-mailpit.log
      stdout_logfile_maxbytes=1MB
      stderr_logfile=#{var}/log/digitalspace-supervisor-mailpit.err
      stderr_logfile_maxbytes=1MB
      autorestart=true
      stopasgroup=true
      EOS
  rescue StandardError
      nil
  end

  def post_install
    if !(etc / ".msmtprc").exist?
      (etc / ".msmtprc").write(mailpit_msmtprc_config)
      (etc / ".msmtprc").chmod(0644)
    end

    (etc/"digitalspace-supervisor.d").mkpath
    (etc/"digitalspace-supervisor.d"/"mailpit.ini").delete if (etc/"digitalspace-supervisor.d"/"mailpit.ini").exist?
    (etc/"digitalspace-supervisor.d"/"mailpit.ini").write(supervisor_config)
  end

  service do
    run [
      "#{opt_bin}/digitalspace-mailpit",
      "--listen",
      "127.0.0.1:8025",
      "--smtp",
      "127.0.0.1:1025",
    ]
    working_dir HOMEBREW_PREFIX
    keep_alive true
    log_path "#{var}/log/digitalspace-service-mailpit.log"
    error_log_path "#{var}/log/digitalspace-service-mailpit-error.log"
  end
end
