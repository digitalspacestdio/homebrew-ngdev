class DigitalspaceLuaRestyCore < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-resty-core"
  url "https://github.com/openresty/lua-resty-core/archive/refs/tags/v0.1.27.tar.gz"
  sha256 "39baab9e2b31cc48cecf896cea40ef6e80559054fd8a6e440cc804a858ea84d4"
  head "https://github.com/openresty/lua-resty-core.git", branch: "master"
  revision 109

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/109/digitalspace-lua-resty-core"
    sha256 cellar: :any_skip_relocation, ventura:      "b3ada95ec3cfc722c426cb0db8c79cd8cd164e363aa3c15c94e3f40dd03e7557"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "0488d53023664fb2db7db7560aa40303e91dff821b530646d594ed4ab6431231"
  end

  def install
    pkgshare.install Dir["*"]
  end
end
