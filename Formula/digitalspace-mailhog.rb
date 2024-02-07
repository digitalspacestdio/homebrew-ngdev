class DigitalspaceMailhog < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/digitalspace-mailhog"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8a6c052c88cca886ea306a187d2ce499a6c0b139d288a0267a7002f3e57aa4aa"
  end

  depends_on "mailhog"

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