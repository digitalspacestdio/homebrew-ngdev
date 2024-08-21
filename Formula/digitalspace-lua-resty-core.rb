class DigitalspaceLuaRestyCore < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-resty-core"
  url "https://github.com/openresty/lua-resty-core/archive/refs/tags/v0.1.27.tar.gz"
  sha256 "39baab9e2b31cc48cecf896cea40ef6e80559054fd8a6e440cc804a858ea84d4"
  head "https://github.com/openresty/lua-resty-core.git", branch: "master"
  revision 106

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/digitalspacestdio/ngdev/digitalspace-lua-resty-core"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "02c3522f2da4f12756654235be855263851dda6948de96b9ca994432bfef0fb7"
  end

  def install
    pkgshare.install Dir["*"]
  end
end