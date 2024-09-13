class DigitalspaceLuaRestyCore < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-resty-core"
  url "https://github.com/openresty/lua-resty-core/archive/refs/tags/v0.1.27.tar.gz"
  sha256 "39baab9e2b31cc48cecf896cea40ef6e80559054fd8a6e440cc804a858ea84d4"
  head "https://github.com/openresty/lua-resty-core.git", branch: "master"
  revision 107

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/digitalspace-lua-resty-core"
    sha256 cellar: :any_skip_relocation, monterey:     "1828a40449da48f0a2f68003e2297ed9b52f657d114cdb0ec39256fbf09deb63"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ee522dad0bde950f7d8481e3e644f7967ee1f80c9ffc073b46c93f03c2f0f804"
  end

  def install
    pkgshare.install Dir["*"]
  end
end