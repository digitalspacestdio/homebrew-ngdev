class DigitalspaceLuaRestyCore < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-resty-core"
  url "https://github.com/openresty/lua-resty-core/archive/refs/tags/v0.1.27.tar.gz"
  sha256 "39baab9e2b31cc48cecf896cea40ef6e80559054fd8a6e440cc804a858ea84d4"
  head "https://github.com/openresty/lua-resty-core.git", branch: "master"
  revision 107

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/107/digitalspace-lua-resty-core"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9f5af803a3f70cbf717e92fc79d0bf0b5bf3c243613c37086d9a8d8f47869f3b"
  end

  def install
    pkgshare.install Dir["*"]
  end
end