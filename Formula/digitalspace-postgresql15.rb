class DigitalspacePostgresql15 < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "15"
  revision 1

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/nextgen-devenv/digitalspace-postgresql15"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "4423e9ef9a6ba2bfa786356a31c44a05ddfc2a2da630b55277ec13d15f2f2284"
    sha256 cellar: :any_skip_relocation, sonoma:        "f7d5c27655ffcd98b57fcb9fea3bc44461644b7e35fe6600c8e05dbeaf73bd41"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "5e9d9a59257f8c6509f40be6eefed343c93ef5882e21e41d1d8acac3b46cd0a4"
  end

  depends_on 'postgresql@15'

  def postgresql_listen_address
    "127.0.0.1"
  end

  def postgresql_listen_port
    "5432"
  end

  def postgresql_base_dir
    opt_prefix
  end

  def postgresql_data_dir
    var / "lib" / "postgresql" / "15"
  end

  def postgresql_tmp_dir
    "/tmp"
  end

  def postgresql_log_dir
    var / "log" / "postgresql" / "15"
  end

  def postgresql_client_script
    <<~EOS
    #!/bin/sh
    exec #{Formula["postgresql@15"].opt_bin}/psql -U postgres --host=#{postgresql_listen_address} --port=#{postgresql_listen_port} "$@"
    EOS
  rescue StandardError
      nil
  end

  def install
    (buildpath / "bin" / "psql15").write(postgresql_client_script)
    (buildpath / "bin" / "psql15").chmod(0755)
    bin.install "bin/psql15"
  end

  def post_install
    postgresql_log_dir.mkpath
    if !postgresql_data_dir.exist?
      postgresql_data_dir.mkpath
      system "#{Formula["postgresql@15"].opt_bin}/initdb", "--username=postgres", "--locale=C", "-E", "UTF-8", postgresql_data_dir
    end

    supervisor_config =<<~EOS
      [program:postgresql15]
      command=#{Formula["postgresql@15"].opt_bin}/postgres -D #{postgresql_data_dir}
      environment=LC_ALL=C
      directory=#{opt_prefix}
      stdout_logfile=#{var}/log/digitalspace-supervisor-postgresql15.log
      stdout_logfile_maxbytes=1MB
      stderr_logfile=#{var}/log/digitalspace-supervisor-postgresql15.err
      stderr_logfile_maxbytes=1MB
      user=#{ENV['USER']}
      autorestart=true
      stopasgroup=true
    EOS

    (etc/"digitalspace-supervisor.d").mkpath
    (etc/"digitalspace-supervisor.d"/"postgresql15.ini").delete if (etc/"digitalspace-supervisor.d"/"postgresql15.ini").exist?
    (etc/"digitalspace-supervisor.d"/"postgresql15.ini").write(supervisor_config) unless (etc/"digitalspace-supervisor.d"/"postgresql15.ini").exist?
  end

  service do
    run [Formula["postgresql@15"].opt_bin/"postgres", "-D", f.postgresql_data_dir]
    environment_variables LC_ALL: "C"
    keep_alive true
    require_root false
    log_path var/"log/digitalspace-service-postgresql15.log"
    error_log_path var/"log/digitalspace-service-postgresql15.log"
    working_dir HOMEBREW_PREFIX
  end
end