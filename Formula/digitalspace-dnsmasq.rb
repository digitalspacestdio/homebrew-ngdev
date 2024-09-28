class DigitalspaceDnsmasq < Formula
  desc "Lightweight DNS forwarder and DHCP server"
  homepage "https://thekelleys.org.uk/dnsmasq/doc.html"
  url "https://thekelleys.org.uk/dnsmasq/dnsmasq-2.89.tar.gz"
  sha256 "8651373d000cae23776256e83dcaa6723dee72c06a39362700344e0c12c4e7e4"
  license any_of: ["GPL-2.0-only", "GPL-3.0-only"]
  revision 110

  livecheck do
    url "https://thekelleys.org.uk/dnsmasq/"
    regex(/href=.*?dnsmasq[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/110/digitalspace-dnsmasq"
    sha256 cellar: :any_skip_relocation, ventura:      "0feacd6339aaf9418b17dc20df671c233dc82d17f88bd0f4b5d53a7237bf0dff"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a8ab217270be3f9ba861f83a4f60b677d2e45e9803ad09cca4210906f91864d6"
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
    # Fix compilation on newer macOS versions.
    ENV.append_to_cflags "-D__APPLE_USE_RFC_3542"

    inreplace "Makefile" do |s|
      s.change_make_var! "CFLAGS", ENV.cflags || ""
      s.change_make_var! "LDFLAGS", ENV.ldflags || ""
    end

    if Hardware::CPU.intel?
      ENV.append "CFLAGS", "-march=ivybridge"
      ENV.append "CFLAGS", "-msse4.2"

      ENV.append "CXXFLAGS", "-march=ivybridge"
      ENV.append "CXXFLAGS", "-msse4.2"
    end

    ENV.append "CFLAGS", "-O2"
    ENV.append "CXXFLAGS", "-O2"

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

  def post_install
    begin
        inreplace etc / "digitalspace-dnsmasq.conf" do |s|
          s.sub!(/^.*?port=.*$/, "port=53")
        end
    rescue StandardError
        nil
    end
    
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
