class DigitalspaceNginxLuaModule < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-nginx-module"
  url "https://github.com/openresty/lua-nginx-module/archive/v0.10.25.tar.gz"
  sha256 "bc764db42830aeaf74755754b900253c233ad57498debe7a441cee2c6f4b07c2"
  head "https://github.com/openresty/lua-nginx-module.git", branch: "master"
  revision 3

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/digitalspace-nginx-lua-module"
    sha256 cellar: :any_skip_relocation, sonoma:       "455412d36ed1f2f9f7caccc48903cd56c35168f09b55c1308a0e24eb95e978f2"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "3a1cb80d02117a5354a6c4eda3ab08e87c805ae73a7d8f9c6f709a59306efd64"
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