class DigitalspaceNgxDevelKit < Formula
  desc "Nginx Development Kit"
  homepage "https://github.com/simpl/ngx_devel_kit"
  url "https://github.com/simpl/ngx_devel_kit/archive/v0.3.2.tar.gz"
  sha256 "aa961eafb8317e0eb8da37eb6e2c9ff42267edd18b56947384e719b85188f58b"
  head "https://github.com/simpl/ngx_devel_kit.git", branch: "master"
  revision 109

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/109/digitalspace-ngx-devel-kit"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "79997aee24ed3710cac2c9e7c9a8f70db7543fd3486fc65b45f482a4e2367753"
  end
  
  def install
    pkgshare.install Dir["*"]
  end
end
