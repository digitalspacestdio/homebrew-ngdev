class DigitalspaceNgxDevelKit < Formula
  desc "Nginx Development Kit"
  homepage "https://github.com/simpl/ngx_devel_kit"
  url "https://github.com/simpl/ngx_devel_kit/archive/v0.3.2.tar.gz"
  sha256 "aa961eafb8317e0eb8da37eb6e2c9ff42267edd18b56947384e719b85188f58b"
  head "https://github.com/simpl/ngx_devel_kit.git", branch: "master"
  revision 107

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/107/digitalspace-ngx-devel-kit"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "f51acc932e9d0ad9a6f9a8f91b30c80ab3dc9317858729db24dae861923de6c5"
    sha256 cellar: :any_skip_relocation, monterey:       "18564e35b53698efb03228a0ce0deb7e2a6d73102aeab93f06776f8b15d62665"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "dd5e1f9e70fa5008ac5be00643a3f6c59f43e07ae7bd3f98173174bb0b6594e5"
  end
  
  def install
    pkgshare.install Dir["*"]
  end
end
