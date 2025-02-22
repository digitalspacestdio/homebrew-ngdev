class DigitalspaceLuaRestyCore < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-resty-core"
  url "https://github.com/openresty/lua-resty-core/archive/refs/tags/v0.1.27.tar.gz"
  sha256 "39baab9e2b31cc48cecf896cea40ef6e80559054fd8a6e440cc804a858ea84d4"
  head "https://github.com/openresty/lua-resty-core.git", branch: "master"
  revision 111

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/111/digitalspace-lua-resty-core"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "2e590214bc27c80d6d69e4e222e23a0a61b794a6eac65f469e85596eac9990e6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "c958e22836fcc0381105fac91ea916c04eeb6956f053e27d01390f61a338c21c"
  end

  def install
    pkgshare.install Dir["*"]
  end
end
