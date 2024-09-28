class DigitalspaceMailhog < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"
  revision 110

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/110/digitalspace-mailhog"
    sha256 cellar: :any_skip_relocation, ventura:      "a17c01c4250737bc4b1ce8628486a35eaaeb3a4eb6db9f6ea90c75329bb0e701"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "053c063b0e1512a107a144631f87afde7b3e2333cc7b33c4bcac9cdca8e7cadb"
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
