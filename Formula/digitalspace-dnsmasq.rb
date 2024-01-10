class DigitalspaceDnsmasq < Formula
  desc "Lightweight DNS forwarder and DHCP server"
  homepage "https://thekelleys.org.uk/dnsmasq/doc.html"
  url "https://thekelleys.org.uk/dnsmasq/dnsmasq-2.89.tar.gz"
  sha256 "8651373d000cae23776256e83dcaa6723dee72c06a39362700344e0c12c4e7e4"
  license any_of: ["GPL-2.0-only", "GPL-3.0-only"]
  revision 5

  livecheck do
    url "https://thekelleys.org.uk/dnsmasq/"
    regex(/href=.*?dnsmasq[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "pkg-config" => :build

  def start_script_macos
    <<~EOS
      #!/bin/bash
      set -e
      set -x
      if [[ $(id -u ${USER}) != 0 ]]; then
        sudo mkdir -p /etc/resolver
        echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/dev.com
        echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/loc.com
        echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/dev.local
        sudo cp #{HOMEBREW_PREFIX}/opt/digitalspace-dnsmasq/homebrew.mxcl.digitalspace-dnsmasq.plist /Library/LaunchDaemons/homebrew.mxcl.digitalspace-dnsmasq.plist
        sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.digitalspace-dnsmasq.plist
        exit 0
      fi
      mkdir -p /etc/resolver
      echo "nameserver 127.0.0.1" | tee /etc/resolver/dev.com
      echo "nameserver 127.0.0.1" | tee /etc/resolver/loc.com
      echo "nameserver 127.0.0.1" | tee /etc/resolver/dev.local
      cp #{HOMEBREW_PREFIX}/opt/digitalspace-dnsmasq/homebrew.mxcl.digitalspace-dnsmasq.plist /Library/LaunchDaemons/homebrew.mxcl.digitalspace-dnsmasq.plist
      launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.digitalspace-dnsmasq.plist
      EOS
  rescue StandardError
      nil
  end

  def stop_script_macos
    <<~EOS
      #!/bin/bash
      set -e
      set -x
      if [[ $(id -u ${USER}) != 0 ]]; then
        if [[ -f /Library/LaunchDaemons/homebrew.mxcl.digitalspace-dnsmasq.plist ]]; then
          sudo launchctl unload -w /Library/LaunchDaemons/homebrew.mxcl.digitalspace-dnsmasq.plist > /dev/null 2>&1
        fi
        sudo rm /etc/resolver/dev.com
        sudo rm /etc/resolver/loc.com
        sudo rm /etc/resolver/dev.local
        sudo chown -R  #{ENV['USER']} #{prefix}
        exit 0
      fi
      if [[ -f /Library/LaunchDaemons/homebrew.mxcl.digitalspace-dnsmasq.plist ]]; then
        launchctl unload -w /Library/LaunchDaemons/homebrew.mxcl.digitalspace-dnsmasq.plist > /dev/null 2>&1
      fi
      rm /etc/resolver/dev.com
      rm /etc/resolver/loc.com
      rm /etc/resolver/dev.local
      chown -R  #{ENV['USER']} #{prefix}
      EOS
  rescue StandardError
      nil
  end

  def start_script_linux
      <<~EOS
        #!/bin/bash
        set -e
        
        if [[ $(id -u ${USER}) != 0 ]]; then
          if [[ -f /etc/systemd/resolved.conf ]] && [[ ! -f /etc/systemd/resolved.conf.backup ]]; then
            sudo cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.backup
          fi

          sudo sed -i 's/[#\\n]DNS=./DNS=127.0.1.1/g' /etc/systemd/resolved.conf
          sudo cp #{HOMEBREW_PREFIX}/opt/digitalspace-dnsmasq/homebrew.digitalspace-dnsmasq.service /etc/systemd/system/homebrew.digitalspace-dnsmasq.service
          sudo systemctl daemon-reload
          sudo systemctl enable --now homebrew.digitalspace-dnsmasq.service
          if systemctl list-units | grep systemd-resolved.service > /dev/null; then
            sudo systemctl restart systemd-resolved.service
          fi
          exit 0
        fi
        
        if [[ -f /etc/systemd/resolved.conf ]] && [[ ! -f /etc/systemd/resolved.conf.backup ]]; then
          cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.backup
        fi

        sed -i 's/[#\\n]DNS=./DNS=127.0.1.1/g' /etc/systemd/resolved.conf
        cp #{HOMEBREW_PREFIX}/opt/digitalspace-dnsmasq/homebrew.digitalspace-dnsmasq.service /etc/systemd/system/homebrew.digitalspace-dnsmasq.service
        sudo systemctl daemon-reload
        sudo systemctl enable --now homebrew.digitalspace-dnsmasq.service
        if systemctl list-units | grep systemd-resolved.service > /dev/null; then
          sudo systemctl restart systemd-resolved.service
        fi
        EOS
  rescue StandardError
      nil
  end

  def stop_script_linux
      <<~EOS
        #!/bin/bash
        echo "not implemented"
        exit 1
        EOS
  rescue StandardError
      nil
  end

  def install
    ENV.deparallelize

    # Fix etc location
    inreplace %w[dnsmasq.conf.example src/config.h man/dnsmasq.8 man/es/dnsmasq.8 man/fr/dnsmasq.8].each do |s|
      s.gsub! "/var/lib/misc/digitalspace-dnsmasq.leases", var/"lib/misc/digitalspace-dnsmasq/dnsmasq.leases"
      s.gsub! "/etc/dnsmasq.conf", etc/"digitalspace-dnsmasq.conf"
      s.gsub! "/var/run/dnsmasq.pid", var/"run/digitalspace-dnsmasq/dnsmasq.pid"
      s.gsub! "/etc/dnsmasq.d", etc/"digitalspace-dnsmasq.d"
      s.gsub! "/etc/ppp/resolv.conf", etc/"digitalspace-dnsmasq.d/ppp/resolv.conf"
      s.gsub! "/etc/dhcpc/resolv.conf", etc/"digitalspace-dnsmasq.d/dhcpc/resolv.conf"
      s.gsub! "/usr/sbin/dnsmasq", HOMEBREW_PREFIX/"sbin/digitalspace-dnsmasq"
      s.gsub! "/^.*?port\s*=.*$/", "port=53"
      #s.gsub! "#conf-dir=#{etc}/digitalspace-dnsmasq.d/,*.conf", "conf-dir=#{etc}/digitalspace-dnsmasq.d/,*.conf"
    end

    # Fix compilation on newer macOS versions.
    ENV.append_to_cflags "-D__APPLE_USE_RFC_3542"

    inreplace "Makefile" do |s|
      s.change_make_var! "CFLAGS", ENV.cflags || ""
      s.change_make_var! "LDFLAGS", ENV.ldflags || ""
    end

    system "make", "install", "PREFIX=#{prefix}"

    mv sbin/"dnsmasq", sbin/"digitalspace-dnsmasq"
    mv share/"man/man8/dnsmasq.8", share/"man/man8/digitalspace-dnsmasq.8"
    

    etc.install "dnsmasq.conf.example" => "digitalspace-dnsmasq.conf"

    on_macos do
      (buildpath / "bin" / "digitalspace-dnsmasq-start").write(start_script_macos)
      (buildpath / "bin" / "digitalspace-dnsmasq-start").chmod(0755)
      bin.install "bin/digitalspace-dnsmasq-start"

      (buildpath / "bin" / "digitalspace-dnsmasq-stop").write(stop_script_macos)
      (buildpath / "bin" / "digitalspace-dnsmasq-stop").chmod(0755)
      bin.install "bin/digitalspace-dnsmasq-stop"
    end

    on_linux do
      (buildpath / "bin" / "digitalspace-dnsmasq-start").write(start_script_linux)
      (buildpath / "bin" / "digitalspace-dnsmasq-start").chmod(0755)
      bin.install "bin/digitalspace-dnsmasq-start"

      (buildpath / "bin" / "digitalspace-dnsmasq-stop").write(stop_script_linux)
      (buildpath / "bin" / "digitalspace-dnsmasq-stop").chmod(0755)
      bin.install "bin/digitalspace-dnsmasq-stop"
    end
  end

  # def supervisor_config
  #     <<~EOS
  #       [program:dnsmasq]
  #       command=#{opt_sbin}/digitalspace-dnsmasq --keep-in-foreground -C '#{etc}/digitalspace-dnsmasq.conf' -7 '#{etc}/digitalspace-dnsmasq.d,*.conf'
  #       directory=#{opt_prefix}
  #       stdout_logfile=#{var}/log/digitalspace-supervisor-dnsmasq.log
  #       stdout_logfile_maxbytes=1MB
  #       stderr_logfile=#{var}/log/digitalspace-supervisor-dnsmasq.err
  #       stderr_logfile_maxbytes=1MB
  #       user=#{ENV['USER']}
  #       autorestart=true
  #       stopasgroup=true
  #       EOS
  # rescue StandardError
  #     nil
  # end

  def post_install

    on_macos do
      begin
          inreplace etc / "digitalspace-dnsmasq.conf" do |s|
            s.sub!(/^.*?listen-address=.*$/, "listen-address=127.0.0.1")
          end
      rescue StandardError
          nil
      end
    end

    on_linux do
      begin
          inreplace etc / "digitalspace-dnsmasq.conf" do |s|
            s.sub!(/^.*?listen-address=.*$/, "listen-address=127.0.1.1")
          end
      rescue StandardError
          nil
      end
    end
    
    (var/"lib/misc/digitalspace-dnsmasq").mkpath
    (var/"run/digitalspace-dnsmasq").mkpath
    (etc/"digitalspace-dnsmasq.d/ppp").mkpath
    (etc/"digitalspace-dnsmasq.d/dhcpc").mkpath

    (etc/"digitalspace-dnsmasq.d").mkpath
    (etc/"digitalspace-dnsmasq.d/zone.dev.local.conf").delete if (etc/"digitalspace-dnsmasq.d/zone.dev.local.conf").exist?
    (etc/"digitalspace-dnsmasq.d/zone.dev.local.conf").write("address=/dev.local/127.0.0.1")

    (etc/"digitalspace-dnsmasq.d/zone.dev.com.conf").delete if (etc/"digitalspace-dnsmasq.d/zone.dev.com.conf").exist?
    (etc/"digitalspace-dnsmasq.d/zone.dev.com.conf").write("address=/dev.com/127.0.0.1")

    (etc/"digitalspace-dnsmasq.d/zone.loc.com.conf").delete if (etc/"digitalspace-dnsmasq.d/zone.loc.com.conf").exist?
    (etc/"digitalspace-dnsmasq.d/zone.loc.com.conf").write("address=/loc.com/127.0.0.1")

    # (etc/"digitalspace-supervisor.d").mkpath
    # (etc/"digitalspace-supervisor.d"/"dnsmasq.ini").delete if (etc/"digitalspace-supervisor.d"/"dnsmasq.ini").exist?
    # (etc/"digitalspace-supervisor.d"/"dnsmasq.ini").write(supervisor_config)
    
    touch etc/"digitalspace-dnsmasq.d/ppp/.keepme"
    touch etc/"digitalspace-dnsmasq.d/dhcpc/.keepme"
  end

  service do
    run [opt_sbin/"digitalspace-dnsmasq", "--keep-in-foreground", "-C", etc/"digitalspace-dnsmasq.conf", "-7", etc/"digitalspace-dnsmasq.d,*.conf"]
    keep_alive true
    require_root true
    log_path var/"log/digitalspace-service-dnsmasq.log"
    error_log_path var/"log/digitalspace-service-dnsmasq-error.log"
  end

  test do
    system "#{sbin}/dnsmasq", "--test"
  end
end
