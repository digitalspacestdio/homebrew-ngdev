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
      step ca init --deployment-type=standalone --address=127.0.0.1:9480 --dns "localhost,ca.localhost,acme.localhost,dns.localhost" --name=localhost-smallstep --acme --provisioner=admin --password-file="#{etc}/step-ca-password"
      EOS
  rescue StandardError
      nil
  end

  def supervisor_config 
    step_path = `#{Formula["step"].opt_bin}/step path --base`.strip
    <<~EOS
    [program:step-ca]
      command=#{Formula["step"].opt_bin}/step-ca #{step_path}/config/ca.json --resolver=127.0.0.1 --password-file=#{etc}/step-ca-password
      directory=#{opt_prefix}
      stdout_logfile=#{var}/log/digitalspace-supervisor-step-ca.log
      stdout_logfile_maxbytes=1MB
      stderr_logfile=#{var}/log/digitalspace-supervisor-step-ca.err
      stderr_logfile_maxbytes=1MB
      #user=
      autorestart=true
      stopasgroup=true
    EOS
  rescue StandardError
    nil
  end

  def install
    (buildpath / "bin" / "digitalspace-step-ca-init").write(script_step_ca_init)
    (buildpath / "bin" / "digitalspace-step-ca-init").chmod(0755)
    bin.install "bin/digitalspace-step-ca-init"

    (buildpath / "etc" / "digitalspace-supervisor.d" / "step-ca.ini").write(supervisor_config)
    pkgetc.install buildpath / "etc" / "digitalspace-supervisor.d"
  end

  step_path = `#{Formula["step"].opt_bin}/step path --base`.strip
  service do
    run ["#{Formula["step"].opt_bin}/step-ca", "#{step_path}/config/ca.json", "--resolver=127.0.0.1", "--password-file=#{etc}/step-ca-password"]
    working_dir HOMEBREW_PREFIX
    keep_alive true
    require_root false
    log_path var/"log/digitalspace-service-step-ca.log"
    error_log_path var/"log/digitalspace-service-step-ca-error.log"
  end

  def post_install
    inreplace pkgetc/"digitalspace-supervisor.d"/"step-ca.ini" do |s|
      s.gsub! "#user=", "user=#{ENV['USER']}", false
    end

    (Formula["digitalspace-supervisor"].etc/"digitalspace-supervisor.d").install_symlink pkgetc / "digitalspace-supervisor.d" / "step-ca.ini"

    step_path = `#{Formula["step"].opt_bin}/step path --base`.strip
    
    (etc/"step-ca-password").write((0...8).map { (65 + rand(26)).chr }.join) if !(etc/"step-ca-password").exist?

    # system("#{bin}/digitalspace-step-ca-init") unless File.exist?("#{step_path}/config/ca.json")
  end
end