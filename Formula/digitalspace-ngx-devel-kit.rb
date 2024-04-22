class DigitalspaceNgxDevelKit < Formula
  desc "Nginx Development Kit"
  homepage "https://github.com/simpl/ngx_devel_kit"
  url "https://github.com/simpl/ngx_devel_kit/archive/v0.3.2.tar.gz"
  sha256 "aa961eafb8317e0eb8da37eb6e2c9ff42267edd18b56947384e719b85188f58b"
  head "https://github.com/simpl/ngx_devel_kit.git", branch: "master"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/nextgen-devenv/digitalspace-ngx-devel-kit"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "fb6bd52197153f379fd024bc841fa6af1dfb3d2557124d97cceb4cad67835446"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "04aac5394d26339c3ae78c1a9daa70cdda7144d3fa989b5318035dba63578e9d"
    sha256 cellar: :any_skip_relocation, sonoma:         "1f8b39c5fb1bf9efbd151e9bc4bf2f920d226832e236549cbeb366a0f617a5d0"
    sha256 cellar: :any_skip_relocation, monterey:       "ec605897332c3a02fe0001e57b74b1d69ce9e6bff8dd8f83420942eb320e7f86"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "91b09bcb1e2c3440f69692a7d16d06c97e5de15fb0394d918528f67688b8eb21"
  end

  revision 2

  # conflicts_with "denji/nginx/ngx-devel-kit"
  
  def install
    pkgshare.install Dir["*"]
  end
end