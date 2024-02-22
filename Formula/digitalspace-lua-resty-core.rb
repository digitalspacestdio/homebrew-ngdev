class DigitalspaceLuaRestyCore < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-resty-core"
  url "https://github.com/openresty/lua-resty-core/archive/refs/tags/v0.1.27.tar.gz"
  sha256 "39baab9e2b31cc48cecf896cea40ef6e80559054fd8a6e440cc804a858ea84d4"
  head "https://github.com/openresty/lua-resty-core.git", branch: "master"
  revision 1

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/nextgen-devenv/digitalspace-lua-resty-core"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "23dfef07d3d2a22ba73b18f48a6d7bcca6d81166830bf3456365fb9b8a867b48"
    sha256 cellar: :any_skip_relocation, sonoma:        "04008c530020979ca713fd32ec6ce38b536397221f97e5416833268a42da4cac"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "0a67b47119afd1037ce5c9598ef13c8c13115a617a2cdc7b85e5887d54511229"
  end

  def install
    pkgshare.install Dir["*"]
  end
end