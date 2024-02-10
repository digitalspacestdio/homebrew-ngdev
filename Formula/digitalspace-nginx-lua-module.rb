class DigitalspaceNginxLuaModule < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-nginx-module"
  url "https://github.com/openresty/lua-nginx-module/archive/v0.10.25.tar.gz"
  sha256 "bc764db42830aeaf74755754b900253c233ad57498debe7a441cee2c6f4b07c2"
  head "https://github.com/openresty/lua-nginx-module.git", branch: "master"
  revision 3

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/nextgen-devenv/digitalspace-nginx-lua-module"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "db0c4ddc61284452d67f3dd213359f70491e4c62a09b518ae04460d96d4dfca2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "b018ab9e64fe1843b4e22564c7ba177720ad23558b96c61257df32082a2bccd6"
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