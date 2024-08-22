class DigitalspaceLuaRestyCore < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-resty-core"
  url "https://github.com/openresty/lua-resty-core/archive/refs/tags/v0.1.27.tar.gz"
  sha256 "39baab9e2b31cc48cecf896cea40ef6e80559054fd8a6e440cc804a858ea84d4"
  head "https://github.com/openresty/lua-resty-core.git", branch: "master"
  revision 106

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/digitalspace-lua-resty-core"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "1675f23779e7dd3d5488e36902588d7c5ceac71f52ff6651b652698adc172986"
    sha256 cellar: :any_skip_relocation, monterey:       "788c3070b142569152be95eea72ee94a70fcf47bc39c68188e260dacfb008101"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "d3173f57494be76fc89c7b5896f6b1dd56dd2fe59758968129a4523826a573de"
  end

  def install
    pkgshare.install Dir["*"]
  end
end