class DigitalspaceNgxDevelKit < Formula
  desc "Nginx Development Kit"
  homepage "https://github.com/simpl/ngx_devel_kit"
  url "https://github.com/simpl/ngx_devel_kit/archive/v0.3.2.tar.gz"
  sha256 "aa961eafb8317e0eb8da37eb6e2c9ff42267edd18b56947384e719b85188f58b"
  head "https://github.com/simpl/ngx_devel_kit.git", branch: "master"
  revision 107

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/digitalspace-ngx-devel-kit"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "bbd5e7e54c71b86e5d1942bed5e6238f43966cdd372290b707a7fdc5f7d74a63"
  end
  
  def install
    pkgshare.install Dir["*"]
  end
end