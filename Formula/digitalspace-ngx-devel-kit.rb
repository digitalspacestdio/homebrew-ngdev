class DigitalspaceNgxDevelKit < Formula
    desc "Nginx Development Kit"
    homepage "https://github.com/simpl/ngx_devel_kit"
    url "https://github.com/simpl/ngx_devel_kit/archive/v0.3.2.tar.gz"
    sha256 "aa961eafb8317e0eb8da37eb6e2c9ff42267edd18b56947384e719b85188f58b"
    head "https://github.com/simpl/ngx_devel_kit.git", branch: "master"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/digitalspace-ngx-devel-kit"
    sha256 cellar: :any_skip_relocation, sonoma:       "6772710b63beaa9287f4d05f43eed55474ad38733f99759c6487bcdb6c65e837"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "2d7545b15a38ca4ecc6746a354e3d672b4fa31cec97ecaf3b99cafb9e9858563"
  end

    # conflicts_with "denji/nginx/ngx-devel-kit"
    
    def install
      pkgshare.install Dir["*"]
    end
  end