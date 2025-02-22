class DigitalspaceOpensearch < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.0.1"
  revision 111

  depends_on 'opensearch'

  def service_wrapper_script
    <<~EOS
    #!/bin/sh
    exec #{Formula["opensearch"].opt_bin}/opensearch "$@"
    EOS
  rescue StandardError
      nil
  end

  def install
    (buildpath / "bin" / "digitalspace-opensearch-service").write(service_wrapper_script)
    (buildpath / "bin" / "digitalspace-opensearch-service").chmod(0755)
    bin.install "bin/digitalspace-opensearch-service"
  end

  def post_install
    supervisor_config =<<~EOS
      [program:opensearch]
      command=#{Formula["opensearch"].opt_bin}/digitalspace-opensearch-service
      directory=#{opt_prefix}
      stdout_logfile=#{var}/log/digitalspace-supervisor-opensearch.log
      stdout_logfile_maxbytes=1MB
      stderr_logfile=#{var}/log/digitalspace-supervisor-opensearch.err
      stderr_logfile_maxbytes=1MB
      user=#{ENV['USER']}
      autorestart=true
      stopasgroup=true
    EOS

    (etc/"digitalspace-supervisor.d").mkpath
    (etc/"digitalspace-supervisor.d"/"opensearch.ini").write(supervisor_config) unless (etc/"digitalspace-supervisor.d"/"opensearch.ini").exist?
  end
end
