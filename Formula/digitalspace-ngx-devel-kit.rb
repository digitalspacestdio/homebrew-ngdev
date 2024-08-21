class DigitalspaceNgxDevelKit < Formula
  desc "Nginx Development Kit"
  homepage "https://github.com/simpl/ngx_devel_kit"
  url "https://github.com/simpl/ngx_devel_kit/archive/v0.3.2.tar.gz"
  sha256 "aa961eafb8317e0eb8da37eb6e2c9ff42267edd18b56947384e719b85188f58b"
  head "https://github.com/simpl/ngx_devel_kit.git", branch: "master"
  revision 106

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/digitalspace-ngx-devel-kit"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8e9115d9b4f82af45b3463284e503a7c40cce96f7c90644f26b720a418dfd58b"
  end
  
  def install
    pkgshare.install Dir["*"]
  end
end