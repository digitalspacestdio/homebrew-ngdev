class DigitalspaceNginxLuaModule < Formula
  desc "Embed the power of Lua into Nginx"
  homepage "https://github.com/openresty/lua-nginx-module"
  url "https://github.com/openresty/lua-nginx-module/archive/v0.10.25.tar.gz"
  sha256 "bc764db42830aeaf74755754b900253c233ad57498debe7a441cee2c6f4b07c2"
  head "https://github.com/openresty/lua-nginx-module.git", branch: "master"
  revision 107

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/107/digitalspace-nginx-lua-module"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "507ee87e1c2e68afdc8ad403f4c9754bd43cc22eddde20eec7a1382ed24e10de"
    sha256 cellar: :any_skip_relocation, monterey:       "91a5aca48b79fc2bb88d12a43bed5cd0ffd9f71947cfcd9d07735a6b1b622061"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "ed199fb78e52e139dfa2bdd99ae51acf6829e1b1a58f0d56f99a360c2f877724"
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
