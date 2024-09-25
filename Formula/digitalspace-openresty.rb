require 'etc'

class DigitalspaceOpenresty < Formula
  desc "Scalable Web Platform by Extending NGINX with Lua"
  homepage "https://openresty.org"
  revision 109

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/107/digitalspace-openresty"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "4ac3fa0ef760afeb499b581fe7c60a3ab3ce1c3d021fd3f866071ff576da070f"
    sha256 cellar: :any_skip_relocation, monterey:       "04446a173affd822b76bfa5e950ea9c4ea856004be317396149040b96d75d081"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "600149c5d2670fbc590aff809426d8e01f32941096fe74f6ba946cb6aaa793d7"
  end

  VERSION = "1.21.4.2".freeze
  url "https://openresty.org/download/openresty-#{VERSION}.tar.gz"
  sha256 "5b1eded25c1d4ed76c0336dfae50bd94d187af9c85ead244135dd5ae363b2e2a"

  keg_only "only for use with digitalspace-nginx"

  option "with-postgresql", "Compile with ngx_http_postgres_module"
  option "with-iconv", "Compile with ngx_http_iconv_module"
  option "with-slice", "Compile with ngx_http_slice_module"

  depends_on "geoip"
  depends_on "digitalspace-openresty-openssl111"
  depends_on "pcre"
  depends_on "postgresql" => :optional

  skip_clean "site"
  skip_clean "pod"
  skip_clean "nginx"
  skip_clean "luajit"

  def install
    # Configure
    cc_opt = "-I#{HOMEBREW_PREFIX}/include -I#{Formula["pcre"].opt_include} -I#{Formula["digitalspace-openresty-openssl111"].opt_include}"
    ld_opt = "-L#{HOMEBREW_PREFIX}/lib -L#{Formula["pcre"].opt_lib} -L#{Formula["digitalspace-openresty-openssl111"].opt_lib}"

    args = %W[
      -j#{Etc.nprocessors}
      --prefix=#{prefix}
      --pid-path=#{var}/run/openresty.pid
      --lock-path=#{var}/run/openresty.lock
      --conf-path=#{etc}/openresty/nginx.conf
      --http-log-path=#{var}/log/nginx/access.log
      --error-log-path=#{var}/log/nginx/error.log
      --with-cc-opt=#{cc_opt}
      --with-ld-opt=#{ld_opt}
      --with-pcre-jit
      --without-http_rds_json_module
      --without-http_rds_csv_module
      --without-lua_rds_parser
      --with-ipv6
      --with-stream
      --with-stream_ssl_module
      --with-stream_ssl_preread_module
      --with-http_v2_module
      --without-mail_pop3_module
      --without-mail_imap_module
      --without-mail_smtp_module
      --with-http_stub_status_module
      --with-http_realip_module
      --with-http_addition_module
      --with-http_auth_request_module
      --with-http_secure_link_module
      --with-http_random_index_module
      --with-http_geoip_module
      --with-http_gzip_static_module
      --with-http_sub_module
      --with-http_dav_module
      --with-http_flv_module
      --with-http_mp4_module
      --with-http_gunzip_module
      --with-threads
      --with-luajit-xcflags=-DLUAJIT_NUMMODE=2\ -DLUAJIT_ENABLE_LUA52COMPAT\ -fno-stack-check
    ]

    args << "--with-http_postgres_module" if build.with? "postgresql"
    args << "--with-http_iconv_module" if build.with? "iconv"
    args << "--with-http_slice_module" if build.with? "slice"

    system "./configure", *args

    # Install
    system "make"
    system "make", "install"
  end

  def caveats
    <<~EOS
      You can find the configuration files for openresty under #{etc}/openresty/.
    EOS
  end

  test do
    system "#{bin}/openresty", "-V"
  end
end
