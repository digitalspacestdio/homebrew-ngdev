class DigitalspaceStepCa < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.0"
  revision 3

  depends_on "step"

  def script_step_ca_init
    <<~EOS
      #!/bin/bash
      set -e
      set -x
      step ca init --context=digitalspace-step-ca --deployment-type=standalone --address=127.0.0.1:9443 --dns=localhost --name=localhost-smallstep --acme --provisioner=$USER@localhost --password-file="#{etc}/step-ca-password"
      EOS
  rescue StandardError
      nil
  end

  def install
    (buildpath / "bin" / "digitalspace-step-ca-init").write(script_step_ca_init)
    (buildpath / "bin" / "digitalspace-step-ca-init").chmod(0755)
    bin.install "bin/digitalspace-step-ca-init"
  end

  step_path = `#{Formula["step"].opt_bin}/step path`
  service do
    run ["#{Formula["step"].opt_bin}/step-ca", "#{step_path.strip}/config/ca.json", "--context=digitalspace-step-ca", "--password-file", etc/"step-ca-password"]
    working_dir HOMEBREW_PREFIX
    keep_alive true
    require_root false
    log_path var/"log/digitalspace-service-step-ca.log"
    error_log_path var/"log/digitalspace-service-step-ca-error.log"
  end

  def post_install
    step_path = `#{Formula["step"].opt_bin}/step path`

    supervisor_config =<<~EOS
      [program:step-ca]
      command=#{Formula["step"].opt_bin}/step-ca #{step_path.strip}/config/ca.json --context=digitalspace-step-ca --password-file #{etc}/step-ca-password
      directory=#{opt_prefix}
      stdout_logfile=#{var}/log/digitalspace-supervisor-step-ca.log
      stdout_logfile_maxbytes=1MB
      stderr_logfile=#{var}/log/digitalspace-supervisor-step-ca.err
      stderr_logfile_maxbytes=1MB
      user=#{ENV['USER']}
      autorestart=true
      stopasgroup=true
    EOS

    (etc/"step-ca-password").write((0...8).map { (65 + rand(26)).chr }.join) if !(etc/"step-ca-password").exist?

    (etc/"digitalspace-supervisor.d").mkpath
    (etc/"digitalspace-supervisor.d"/"step-ca.ini").delete if (etc/"digitalspace-supervisor.d"/"step-ca.ini").exist?
    (etc/"digitalspace-supervisor.d"/"step-ca.ini").write(supervisor_config)
  end
end