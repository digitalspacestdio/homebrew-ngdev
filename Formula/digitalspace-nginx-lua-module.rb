class DigitalspaceNginxLuaModule < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-nginx-module"
  url "https://github.com/openresty/lua-nginx-module/archive/v0.10.25.tar.gz"
  sha256 "bc764db42830aeaf74755754b900253c233ad57498debe7a441cee2c6f4b07c2"
  head "https://github.com/openresty/lua-nginx-module.git", branch: "master"
  revision 110

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/110/digitalspace-nginx-lua-module"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "de265093fd2a6f838ef542b3ac6634d975bf9aaf32e2c9ef4696b1f05a348a2e"
    sha256 cellar: :any_skip_relocation, ventura:       "62d81039e8eb07f56ad004d04712217fa87276b7c9807e53ef726f4b81581e7f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "bca1c65c2a8539e737abd2a431cb82dd1ff1cec5833ba716656fa6819d5c992a"
    sha256 cellar: :any_skip_relocation, aarch64_linux: "bb057a2bd5989ee441add52c2cc1b6fd1602661cc3388eeae694b500abcb5112"
  end

  depends_on "luajit-openresty"
  depends_on "digitalspace-ngx-devel-kit"
  depends_on "digitalspace-openresty"

  def install
    (buildpath / "src" / "ngx_http_lua_autoconf.h").write("")

    pkgshare.install Dir["*"]    
  end

  # def post_install
  #   # configure script tries to write that file and fails
  #   # seems to be empty anyways, this hack makes compile succeed
  #   system "touch",  "#{pkgshare}/src/ngx_http_lua_autoconf.h"
  # end
end
