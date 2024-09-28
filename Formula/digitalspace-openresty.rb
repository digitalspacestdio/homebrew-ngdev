require 'etc'

class DigitalspaceOpenresty < Formula
  desc "Scalable Web Platform by Extending NGINX with Lua"
  homepage "https://openresty.org"
  revision 110

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/110/digitalspace-openresty"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "13a2bc53f6935198b9d1f53a7691c7313a0e2cb7b96ada24ebd72e3a5239d457"
    sha256 cellar: :any_skip_relocation, ventura:       "86a28fe9c96fa83ec84193a55d22828d061ddfd16aa82a7e27f9798306d57ceb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d90b7b6dc9ff4cbff881f95074d4a6a70ad02c781ec250bb5b1a497c44dbb052"
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
    if Hardware::CPU.intel?
      ENV.append "CFLAGS", "-march=ivybridge"
      ENV.append "CFLAGS", "-msse4.2"

      ENV.append "CXXFLAGS", "-march=ivybridge"
      ENV.append "CXXFLAGS", "-msse4.2"
    end

    ENV.append "CFLAGS", "-O2"
    ENV.append "CXXFLAGS", "-O2"

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
