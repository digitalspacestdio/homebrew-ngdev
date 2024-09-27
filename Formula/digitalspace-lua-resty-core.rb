class DigitalspaceLuaRestyCore < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-resty-core"
  url "https://github.com/openresty/lua-resty-core/archive/refs/tags/v0.1.27.tar.gz"
  sha256 "39baab9e2b31cc48cecf896cea40ef6e80559054fd8a6e440cc804a858ea84d4"
  head "https://github.com/openresty/lua-resty-core.git", branch: "master"
  revision 110

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/110/digitalspace-lua-resty-core"
    sha256 cellar: :any_skip_relocation, ventura:      "269b5e4530988563a6d8d2b3a925195e74abfcdae2692baeae65b98c27c7d420"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9114c7df85d50c668c8a5698f5c9852e72e4e997fa2648632fa588df906d1578"
  end

  def install
    pkgshare.install Dir["*"]
  end
end
