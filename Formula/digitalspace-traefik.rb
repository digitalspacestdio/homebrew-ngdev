class DigitalspaceTraefik < Formula
  desc "Modern reverse proxy"
  homepage "https://traefik.io/"
  url "https://github.com/traefik/traefik/releases/download/v2.11.8/traefik-v2.11.8.src.tar.gz"
  sha256 "e95c47584ee9bd041215de0fcf3627215a4ef48a1cca06fdb638132428521fa2"
  license "MIT"
  revision 111

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/111/digitalspace-traefik"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "e05fedc94182e3a8f50a3783c1705eeef7b38a1d065c2a59263e48bf5fbf6b31"
    sha256 cellar: :any_skip_relocation, ventura:       "179be9392e56af6b950c22f1375c9e71209d687d2266ad896f165bc5494b7dec"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "91f2d4590736050e00950125c3dea0e7e32fa3c1fb79f668f6454d62e3c2f55f"
  end

  depends_on "digitalspace-local-ca"
  depends_on "go" => :build
  
  def traefik_main_config
    <<~EOS
      [global]
        checkNewVersion = false
        sendAnonymousUsage = false
      
      [entryPoints]
        [entryPoints.web]
          address = ":80"
        [entryPoints.web.http.redirections.entryPoint]
          to = "default"
          scheme = "https"
          permanent = true
      
      [entryPoints.default]
        address = ":443"
      [entryPoints.default.http.tls]

      [log]
        level = "DEBUG"
        filePath = "#{var}/log/digitalspace-traefik_traefik.log"
      
      [accessLog]
        filePath = "#{var}/log/digitalspace-traefik_access.log"
      
      [api]
        dashboard = true
      
      [serversTransport]
        insecureSkipVerify = true
      
      [providers.file]
        directory = "#{etc}/digitalspace-traefik/conf.d/"
        watch = true

      #[providers.docker]
      #   exposedByDefault = false
      EOS
  rescue StandardError
      nil
  end

  def traefik_enable_docker_reverse_proxy
    <<~EOS
    #!/bin/bash
    set -e

    CONFIG_DIR="#{etc}/digitalspace-traefik/conf.d"
    CONFIG_FILE="#{etc}/digitalspace-traefik/conf.d/docker-reverse-proxy.toml"

    REVERSE_PROXY_SCHEME="${REVERSE_PROXY_SCHEME:-http}"
    REVERSE_PROXY_HOST="${REVERSE_PROXY_HOST:-127.0.0.1}"
    REVERSE_PROXY_PORT="${REVERSE_PROXY_PORT:-1984}"

    mkdir -p "$CONFIG_DIR"

    cat <<EOF > "$CONFIG_FILE"
    [[tls.certificates]]
      certFile = "#{etc}/openssl/localCA/certs/docker.local.crt"
      keyFile = "#{etc}/openssl/localCA/private/docker.local.key"

    [http.routers]
    [http.routers.docker_reverse_proxy]
    rule = "HostRegexp(\\`{subdomain:[a-z0-9-_]+}.docker.local\\`, \\`{subsubdomain:[a-z0-9-_]+}.{subdomain:[a-z0-9-_]+}.docker.local\\`)"
    priority = 100
    service = "docker_reverse_proxy"
    entryPoints = ["default"]
    [[http.routers.docker_reverse_proxy.tls.domains]]
    main = "*.docker.local"
    sans = "docker.local"

    [http.services]
    [http.services.docker_reverse_proxy]
      [http.services.docker_reverse_proxy.loadBalancer]
        [[http.services.docker_reverse_proxy.loadBalancer.servers]]
          url = "${REVERSE_PROXY_SCHEME}://${REVERSE_PROXY_HOST}:${REVERSE_PROXY_PORT}"
    EOF

      echo "Traefik Docker reverse proxy config written to: "
      echo "$CONFIG_FILE"
    EOS
  rescue StandardError
    nil
  end

  def traefik_dashboard_config
    <<~EOS
    [http.routers]
      [http.routers.api]
        rule = "Host(`traefik.dev.local`) && PathPrefix(`/api/`)"
        service = "api@internal"
        entryPoints = ["default"]
        priority = 10000

      [http.routers.traefik]
        rule = "Host(`traefik.dev.local`) && PathPrefix(`/`)"
        service = "dashboard@internal"
        entryPoints = ["default"]
        priority = 5000
    EOS
  rescue StandardError
      nil
  end

  def traefik_snippets_config
    <<~EOS
    [http.middlewares]
      [http.middlewares.redirect-trailing-slash.redirectRegex]
        regex = "^(http|ws)s?:\\\\/\\\\/(www\\\\.){0,1}(([a-z0-9\\\\-_]+?\\\\.)+[a-z0-9\\\\-_]+)(((\\\\/[^\\\\/\\\\?]+)*?)(\\\\/[^\\\\/.\\\\?]+))(\\\\/{0}|\\\\/{2,})(\\\\?{1}.*){0,1}$"
        replacement = "${1}s://${3}${5}/${10}"
        permanent =  true
    
      [http.middlewares.redirect-from-www.redirectRegex]
        regex = "^(http|ws)s?:\\\\/\\\\/www\\\\.(.*)"
        replacement = "${1}s://${2}"
        permanent =  true
    
      [http.middlewares.redirect-secure.redirectRegex]
        regex = "^(http|ws):\\\\/\\\\/(.+)$"
        replacement = "${1}s://${2}"
        permanent =  true
    
      [http.middlewares.redirect-double-slash.redirectRegex]
        regex = "^(http|ws)s?:\\\\/\\\\/(.*\\\\/)\\\\/(.*)$"
        replacement = "${1}s://${2}${3}"
        permanent =  true
    
      [http.middlewares.ratelimit-default.rateLimit]
        average = 100
        burst = 200
        period = "5s"
    
      [http.middlewares.admin-auth.basicAuth]
        # admin / $ecretPassw0rd
        users = [
            "admin:$2y$05$SrVjSbbXSRCqx4nJkJxEtuypRzjmjhrKkKFpTss.PtPbUM/TUwMwC"
        ]
    
      [http.middlewares.gzip.compress]
      [http.middlewares.remove-x-forwarded-for.headers.customRequestHeaders]
        X-Forwarded-For = ""
    EOS
  end

  def traefik_localhost_config
    <<~EOS
    [[tls.certificates]]
      certFile = "#{etc}/openssl/localCA/certs/dev.local.crt"
      keyFile = "#{etc}/openssl/localCA/private/dev.local.key"

    [[tls.certificates]]
      certFile = "#{etc}/openssl/localCA/certs/dev.com.crt"
      keyFile = "#{etc}/openssl/localCA/private/dev.com.key"

    [[tls.certificates]]
      certFile = "#{etc}/openssl/localCA/certs/loc.com.crt"
      keyFile = "#{etc}/openssl/localCA/private/loc.com.key"

    [http.routers]
      [http.routers.dev_com]
        rule = "HostRegexp(`{subdomain:[a-z0-9-_]+}.dev.com`, `{subsubdomain:[a-z0-9-_]+}.{subdomain:[a-z0-9-_]+}.dev.com`)"
        priority = 100
        service = "digitalspace-nginx"
        entryPoints = ["default"]
        middlewares = ["remove-x-forwarded-for"]
        [[http.routers.dev_com.tls.domains]]
        main = "*.dev.com"

      [http.routers.loc_com]
        rule = "HostRegexp(`{subdomain:[a-z0-9-_]+}.loc.com`, `{subsubdomain:[a-z0-9-_]+}.{subdomain:[a-z0-9-_]+}.loc.com`)"
        priority = 110
        service = "digitalspace-nginx"
        entryPoints = ["default"]
        middlewares = ["remove-x-forwarded-for"]
        [[http.routers.loc_com.tls.domains]]
        main = "*.loc.com"

      [http.routers.dev_local]
        rule = "HostRegexp(`{subdomain:[a-z0-9-_]+}.dev.local`, `{subsubdomain:[a-z0-9-_]+}.{subdomain:[a-z0-9-_]+}.dev.local`)"
        priority = 120
        service = "digitalspace-nginx"
        entryPoints = ["default"]
        middlewares = ["remove-x-forwarded-for"]
        [[http.routers.dev_local.tls.domains]]
        main = "*.dev.local"

    [http.services]
      [http.services.digitalspace-nginx]
        [http.services.digitalspace-nginx.loadBalancer]
          [[http.services.digitalspace-nginx.loadBalancer.servers]]
            url = "http://127.0.0.1:1984"
    EOS
  rescue StandardError
      nil
  end

  def binary_wrapper
    <<~EOS
      #!/usr/bin/env bash
      set -e
      
      exec #{Formula["digitalspace-traefik"].opt_bin}/traefik "$@"
    EOS
  rescue StandardError
      nil
  end

  def service_wrapper_script
    <<~EOS
    #!/bin/sh
    if [ -f #{etc}/digitalspace-traefik/traefik.override.toml ]; then
      exec #{Formula["digitalspace-traefik"].opt_bin}/digitalspace-traefik --configfile=#{etc}/digitalspace-traefik/traefik.override.toml
    fi
    
    exec #{Formula["digitalspace-traefik"].opt_bin}/digitalspace-traefik --configfile=#{etc}/digitalspace-traefik/traefik.toml
    EOS
  rescue StandardError
      nil
  end

  def install
    ldflags = %W[
      -s -w
      -X github.com/traefik/traefik/v#{version.major}/pkg/version.Version=#{version}
    ]
    system "go", "generate"
    system "go", "build", *std_go_args(ldflags:, output: bin/"traefik"), "./cmd/traefik"
    mv bin/"traefik", bin/"digitalspace-traefik"
  end

  def supervisor_config
    <<~EOS
      [program:traefik]
      command=#{etc}/digitalspace-traefik/service.sh
      directory=#{opt_prefix}
      stdout_logfile=#{var}/log/digitalspace-supervisor-traefik.log
      stdout_logfile_maxbytes=1MB
      stderr_logfile=#{var}/log/digitalspace-supervisor-traefik.err
      stderr_logfile_maxbytes=1MB
      autorestart=true
      stopasgroup=true
      EOS
  rescue StandardError
      nil
  end

  def post_install
    certs = etc / "digitalspace-traefik" / "certs"
    (etc/"digitalspace-traefik").mkpath
    (etc/"digitalspace-traefik"/"service.sh").delete if (etc/"digitalspace-traefik"/"service.sh").exist?
    (etc/"digitalspace-traefik"/"service.sh").write(service_wrapper_script)
    (etc/"digitalspace-traefik"/"service.sh").chmod(0755)

    (etc/"digitalspace-traefik"/"conf.d").mkpath
    (etc/"digitalspace-traefik"/"traefik.toml").delete if (etc/"digitalspace-traefik"/"traefik.toml").exist?
    (etc/"digitalspace-traefik"/"traefik.toml").write(traefik_main_config)

    bin_path = HOMEBREW_PREFIX/"bin/digitalspace-traefik-enable-docker-proxy"
    bin_path.delete if bin_path.exist?
    bin_path.write(traefik_enable_docker_reverse_proxy)
    bin_path.chmod 0755

    (etc/"digitalspace-traefik"/"conf.d"/"dashboard.toml").delete if (etc/"digitalspace-traefik"/"conf.d"/"dashboard.toml").exist?
    (etc/"digitalspace-traefik"/"conf.d"/"dashboard.toml").write(traefik_dashboard_config)

    (etc/"digitalspace-traefik"/"conf.d"/"localhost.toml").delete if (etc/"digitalspace-traefik"/"conf.d"/"localhost.toml").exist?
    (etc/"digitalspace-traefik"/"conf.d"/"localhost.toml").write(traefik_localhost_config)

    (etc/"digitalspace-traefik"/"conf.d"/"snippets.toml").delete if (etc/"digitalspace-traefik"/"conf.d"/"snippets.toml").exist?
    (etc/"digitalspace-traefik"/"conf.d"/"snippets.toml").write(traefik_snippets_config)

    (etc/"digitalspace-supervisor.d").mkpath
    (etc/"digitalspace-supervisor.d"/"traefik.ini").delete if (etc/"digitalspace-supervisor.d"/"traefik.ini").exist?
    (etc/"digitalspace-supervisor.d"/"traefik.ini").write(supervisor_config)

    system("local-ca-crtgen docker.local") unless File.exist?(etc / "openssl" / "localCA" / "certs" / "docker.local.crt")
    system("local-ca-crtgen dev.local") unless File.exist?(etc / "openssl" / "localCA" / "certs" / "dev.local.crt")
    system("local-ca-crtgen dev.com") unless File.exist?(etc / "openssl" / "localCA" / "certs" / "dev.com.crt")
    system("local-ca-crtgen loc.com") unless File.exist?(etc / "openssl" / "localCA" / "certs" / "loc.com.crt")
    
  end

  # step_path = `#{Formula["step"].opt_bin}/step path --base`

  service do
    run ["#{etc}/digitalspace-traefik/service.sh"]
    working_dir HOMEBREW_PREFIX
    keep_alive true
    require_root true
    log_path var/"log/digitalspace-service-traefik.log"
    error_log_path var/"log/digitalspace-service-traefik-error.log"
    #environment_variables LEGO_CA_CERTIFICATES: "#{step_path.strip}/certs/root_ca.crt"
    #environment_variables LEGO_CA_CERTIFICATES: "#{step_path.strip}/certs/root_ca.crt", ACME_DNS_API_BASE: 'http://auth.localhost:5380', ACME_DNS_STORAGE_PATH: "#{etc}/digitalspace-traefik/acme.json"
  end

  test do
    ui_port = free_port
    http_port = free_port

    (testpath/"traefik.toml").write <<~EOS
      [entryPoints]
        [entryPoints.http]
          address = ":#{http_port}"
        [entryPoints.traefik]
          address = ":#{ui_port}"
      [api]
        insecure = true
        dashboard = true
    EOS

    begin
      pid = fork do
        exec bin/"digitalspace-traefik", "--configfile=#{testpath}/traefik.toml"
      end
      sleep 8
      cmd_ui = "curl -sIm3 -XGET http://127.0.0.1:#{http_port}/"
      assert_match "404 Not Found", shell_output(cmd_ui)
      sleep 1
      cmd_ui = "curl -sIm3 -XGET http://127.0.0.1:#{ui_port}/dashboard/"
      assert_match "200 OK", shell_output(cmd_ui)
    ensure
      Process.kill(9, pid)
      Process.wait(pid)
    end

    assert_match version.to_s, shell_output("#{bin}/digitalspace-traefik version 2>&1")
  end
end
