class DigitalspaceNginxLuaModule < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-nginx-module"
  url "https://github.com/openresty/lua-nginx-module/archive/v0.10.25.tar.gz"
  sha256 "bc764db42830aeaf74755754b900253c233ad57498debe7a441cee2c6f4b07c2"
  head "https://github.com/openresty/lua-nginx-module.git", branch: "master"
  revision 1

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/digitalspace-nginx-lua-module"
    sha256 cellar: :any_skip_relocation, sonoma:       "a0d945c242140f8fc87ee020f024a9adf7ff18877515b2e0124b0c82de6f4ae1"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "0251e72c3734c464925ddbb45c9f22b7bbf6fa81edf56d5bfea1c6593d4b22d9"
  end

  depends_on "luajit-openresty"
  depends_on "denji/nginx/ngx-devel-kit"
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