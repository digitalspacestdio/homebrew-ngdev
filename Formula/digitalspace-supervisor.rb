class DigitalspaceSupervisor < Formula
  include Language::Python::Virtualenv

  desc "Super Process Control System for DigitalSpace Services"
  homepage "http://supervisord.org/"
  url "https://files.pythonhosted.org/packages/a9/b5/37e7a3706de436a8a2d75334711dad1afb4ddffab09f25e31d89e467542f/supervisor-4.3.0.tar.gz"
  sha256 "4a2bf149adf42997e1bb44b70c43b613275ec9852c3edacca86a9166b27e945e"
  license "BSD-3-Clause-Modification"
  head "https://github.com/Supervisor/supervisor.git", branch: "main"

  revision 112

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/112/digitalspace-supervisor"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "09f74a0837a0934476a5ab3ae60fd3f750d95fb101d03ecd9d289c454b68bfa1"
  end

  depends_on "python@3.11"

  def log_dir
      var / "log"
  end

  def apps_dir
    etc / "digitalspace-supervisor.d"
  end

  def legacy_plist_paths
    ["homebrew.mxcl.#{name}"].reject { |n| n == plist_name }.map { |n| "/Library/LaunchDaemons/#{n}.plist" }
  end

  def legacy_service_names
    ["homebrew.#{name}"].reject { |n| n == service_name }
  end

  def service_script
    <<~EOS
      #!/bin/bash
      set -e
      if [[ $(id -u ${USER}) != 0 ]]; then
        echo "You must run this script under the root user!"
        exit 1
      fi
      
      exec #{opt_bin}/digitalspace-supervisord "$@"
      EOS
  rescue StandardError
      nil
  end

  def start_script_macos
    <<~EOS
      #!/bin/bash
      set -e
      if [[ $(id -u ${USER}) != 0 ]]; then
        exec sudo "$0" "$@"
      fi

      for LEGACY_PLIST in #{legacy_plist_paths.join(" ")}; do
        if [[ -f $LEGACY_PLIST ]]; then
          launchctl unload -w $LEGACY_PLIST > /dev/null 2>&1 || true
          rm -f $LEGACY_PLIST
        fi
      done

      cp #{opt_prefix}/#{plist_name}.plist /Library/LaunchDaemons/#{plist_name}.plist
      launchctl load -w /Library/LaunchDaemons/#{plist_name}.plist

      EOS
  rescue StandardError
      nil
  end

  def start_script_linux
    <<~EOS
      #!/bin/bash
      set -e
      if [[ $(id -u ${USER}) != 0 ]]; then
        exec sudo "$0" "$@"
      fi

      for LEGACY_SERVICE in #{legacy_service_names.join(" ")}; do
        if [[ -f /etc/systemd/system/$LEGACY_SERVICE.service ]]; then
          systemctl disable --now $LEGACY_SERVICE.service || true
          rm -f /etc/systemd/system/$LEGACY_SERVICE.service
        fi
      done

      cp #{opt_prefix}/#{service_name}.service /etc/systemd/system/#{service_name}.service
      systemctl daemon-reload
      systemctl enable --now #{service_name}.service

      EOS
  rescue StandardError
      nil
  end

  def stop_script_macos
    <<~EOS
      #!/bin/bash
      set -e
      if [[ $(id -u ${USER}) != 0 ]]; then
        exec sudo "$0" "$@"
      fi
      for PLIST in /Library/LaunchDaemons/#{plist_name}.plist #{legacy_plist_paths.join(" ")}; do
        if [[ -f $PLIST ]]; then
          launchctl unload -w $PLIST > /dev/null 2>&1 || true
        fi
      done
      chown -R #{ENV['USER']} #{prefix}
      EOS
  rescue StandardError
      nil
  end

  def stop_script_linux
    <<~EOS
      #!/bin/bash
      set -e
      if [[ $(id -u ${USER}) != 0 ]]; then
        exec sudo "$0" "$@"
      fi
      for SERVICE in #{service_name} #{legacy_service_names.join(" ")}; do
        if [[ -f /etc/systemd/system/$SERVICE.service ]]; then
          systemctl disable --now $SERVICE.service || true
          rm -f /etc/systemd/system/$SERVICE.service
        fi
      done
      chown -R #{ENV['USER']} #{prefix}
      EOS
  rescue StandardError
      nil
  end

  def digitalspace_supctl_script
    <<~EOS
      #!/bin/bash
      set -e
      exec #{opt_bin}/digitalspace-supervisorctl -c #{etc}/digitalspace-supervisor.conf "$@"
      EOS
  rescue StandardError
      nil
  end

  def install
    inreplace buildpath/"supervisor/skel/sample.conf" do |s|
      s.gsub! %r{/tmp/supervisor\.sock}, var/"run/digitalspace-supervisor.sock"
      s.gsub! %r{/tmp/supervisord\.log}, var/"log/digitalspace-supervisor.log"
      s.gsub! %r{/tmp/supervisord\.pid}, var/"run/digitalspace-supervisor.pid"
      s.gsub!(/^;user=supervisord/, "user=root")
      s.gsub!(/^;chmod=.*/, "chmod=0777")
      s.gsub!(/^;\[include\]$/, "[include]")
      s.gsub! %r{^;files = relative/directory/\*\.ini$}, "files = #{etc}/digitalspace-supervisor.d/*.ini"
      s.gsub!(/^;\[inet_http_server\]/, "[inet_http_server]")
      s.gsub!(/^;port=127.0.0.1:9001/, "port=127.0.0.1:9001")
    end

    virtualenv_install_with_resources

    (buildpath / "bin" / "digitalspace-supervisord-service").write(service_script)
    (buildpath / "bin" / "digitalspace-supervisord-service").chmod(0755)
    bin.install "bin/digitalspace-supervisord-service"

    (buildpath / "bin" / "digitalspace-supctl").write(digitalspace_supctl_script)
    (buildpath / "bin" / "digitalspace-supctl").chmod(0755)
    bin.install "bin/digitalspace-supctl"

    mv bin/"supervisord", bin/"digitalspace-supervisord"
    mv bin/"supervisorctl", bin/"digitalspace-supervisorctl"
    mv bin/"pidproxy", bin/"digitalspace-pidproxy"
    mv bin/"echo_supervisord_conf", bin/"digitalspace-echo_supervisord_conf"

    bin.write_exec_script libexec/"digitalspace-supervisor-start"
    bin.write_exec_script libexec/"digitalspace-supervisor-stop"

    etc.install buildpath/"supervisor/skel/sample.conf" => "digitalspace-supervisor.conf"
    log_dir.mkpath
    apps_dir.mkpath
  end

  def post_install
    
    if File.exist?(opt_bin / "digitalspace-supervisor-start")
      File.delete(opt_bin / "digitalspace-supervisor-start")
    end

    if File.exist?(opt_bin / "digitalspace-supervisor-stop")
      File.delete(opt_bin / "digitalspace-supervisor-stop")
    end

    on_macos do
      (opt_bin / "digitalspace-supervisor-start").write(start_script_macos)
      (opt_bin / "digitalspace-supervisor-start").chmod(0755)

      (opt_bin / "digitalspace-supervisor-stop").write(stop_script_macos)
      (opt_bin / "digitalspace-supervisor-stop").chmod(0755)
    end

    on_linux do
      (opt_bin / "digitalspace-supervisor-start").write(start_script_linux)
      (opt_bin / "digitalspace-supervisor-start").chmod(0755)

      (opt_bin / "digitalspace-supervisor-stop").write(stop_script_linux)
      (opt_bin / "digitalspace-supervisor-stop").chmod(0755)
    end

    (var/"run").mkpath
    (var/"log").mkpath
    conf_warn = <<~EOS
      The default location for supervisor's config file is now:
        #{etc}/digitalspace-supervisor.conf
      Please move your config file to this location and restart supervisor.
    EOS
    old_conf = etc/"digitalspace-supervisor.ini"
    opoo conf_warn if old_conf.exist?
  end

  service do
    run [opt_bin/"digitalspace-supervisord-service", "-c", etc/"digitalspace-supervisor.conf", "--nodaemon"]
    keep_alive true
  end

  test do
    (testpath/"sd.ini").write <<~EOS
      [unix_http_server]
      file=#{var}/run/digitalspace-supervisor.sock

      [supervisord]
      loglevel=debug

      [rpcinterface:supervisor]
      supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

      [supervisorctl]
      serverurl=unix://#{var}/run/digitalspace-supervisor.sock
    EOS

    begin
      pid = fork { exec bin/"digitalspace-supervisord", "--nodaemon", "-c", "sd.ini" }
      sleep 1
      output = shell_output("#{bin}/digitalspace-supervisorctl -c sd.ini version")
      assert_match version.to_s, output
    ensure
      Process.kill "TERM", pid
    end
  end
end
