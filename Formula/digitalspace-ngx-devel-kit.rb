class DigitalspaceNgxDevelKit < Formula
  desc "Nginx Development Kit"
  homepage "https://github.com/simpl/ngx_devel_kit"
  url "https://github.com/simpl/ngx_devel_kit/archive/v0.3.2.tar.gz"
  sha256 "aa961eafb8317e0eb8da37eb6e2c9ff42267edd18b56947384e719b85188f58b"
  head "https://github.com/simpl/ngx_devel_kit.git", branch: "master"
  revision 110

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/110/digitalspace-ngx-devel-kit"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "12192199123b9623410f650f55ece0a8aa50104f0507a3a87f2a83e03f75939e"
    sha256 cellar: :any_skip_relocation, ventura:       "0a9e99a7169db3603ed073881b91be21963cac56027f910078668b427bfa5602"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "140ae046a073804967639938263a0ac6a7597a3d904c1380ff8ac532b0ce3b87"
  end
  
  def install
    pkgshare.install Dir["*"]
  end
end
