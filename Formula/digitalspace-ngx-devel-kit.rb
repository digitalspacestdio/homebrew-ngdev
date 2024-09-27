class DigitalspaceNgxDevelKit < Formula
  desc "Nginx Development Kit"
  homepage "https://github.com/simpl/ngx_devel_kit"
  url "https://github.com/simpl/ngx_devel_kit/archive/v0.3.2.tar.gz"
  sha256 "aa961eafb8317e0eb8da37eb6e2c9ff42267edd18b56947384e719b85188f58b"
  head "https://github.com/simpl/ngx_devel_kit.git", branch: "master"
  revision 110

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/110/digitalspace-ngx-devel-kit"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "b24cdfcc0d5e8b3132ccdd7f3a53806e29ebba09cc97e71f11d5b83f6460c9b0"
  end
  
  def install
    pkgshare.install Dir["*"]
  end
end
