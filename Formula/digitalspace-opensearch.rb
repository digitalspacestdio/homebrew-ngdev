class DigitalspaceOpensearch < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.0.1"
  revision 111

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/111/digitalspace-opensearch"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "9fba17d75105ad87fbc89958c6528696b875e7d181b7101d5164242c779ecb82"
    sha256 cellar: :any_skip_relocation, ventura:       "4da963235f8959331657d970c50b191637e0de1f4bc35b52b19b961f9f3e4753"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d184512bbd4213399c9b5e36f0d3cad28959700306a597176f36b99871a13d78"
  end

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
      command=#{Formula["digitalspace-opensearch"].opt_bin}/digitalspace-opensearch-service
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
