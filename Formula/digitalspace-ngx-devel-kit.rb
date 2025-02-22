class DigitalspaceNgxDevelKit < Formula
  desc "Nginx Development Kit"
  homepage "https://github.com/simpl/ngx_devel_kit"
  url "https://github.com/simpl/ngx_devel_kit/archive/v0.3.2.tar.gz"
  sha256 "aa961eafb8317e0eb8da37eb6e2c9ff42267edd18b56947384e719b85188f58b"
  head "https://github.com/simpl/ngx_devel_kit.git", branch: "master"
  revision 111

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/111/digitalspace-ngx-devel-kit"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "c0271798be7888ec8de029d262bc2be7334a3b6ec348c98bbb55dfa6516cbb8e"
    sha256 cellar: :any_skip_relocation, ventura:       "10d37f8b98851fe7b35618b1a3f644cca554381fb07c4625ca9f0a4783ee1685"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "13ae141e7f0d23e9ac6980aa18f5b291b46bf5479c51945b092aa3fdba515484"
  end
  
  def install
    pkgshare.install Dir["*"]
  end
end
