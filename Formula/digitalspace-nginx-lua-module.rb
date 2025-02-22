class DigitalspaceNginxLuaModule < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-nginx-module"
  url "https://github.com/openresty/lua-nginx-module/archive/v0.10.25.tar.gz"
  sha256 "bc764db42830aeaf74755754b900253c233ad57498debe7a441cee2c6f4b07c2"
  head "https://github.com/openresty/lua-nginx-module.git", branch: "master"
  revision 111

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/111/digitalspace-nginx-lua-module"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "7c737da9e61465f583604f71fe39f00ce1e5d378bb4dc038c374d0a7a471cff7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "da5b631f6070f0eeee2b75954d5f0454fd937cc4816285515ec649d699175b56"
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
