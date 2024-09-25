class DigitalspaceOpenrestyOpenssl111 < Formula
  desc "This OpenSSL 1.1.1 library build is specifically for OpenResty uses"
  homepage "https://www.openssl.org/"
  revision 109

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/109/digitalspace-openresty-openssl111"
    sha256 cellar: :any_skip_relocation, ventura:      "b4493c299b8c60e9f25f92f5e9225727781c79c8108ebd7c7a69bca2a3ffa147"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "b06004d49932d13035eda66d5f8b2feda6800bc37dd30db91f83ccff010277c0"
  end

  VERSION = "1.1.1n".freeze
  stable do
    url "https://www.openssl.org/source/openssl-#{VERSION}.tar.gz"
    mirror "https://openresty.org/download/openssl-#{VERSION}.tar.gz"
    sha256 "40dceb51a4f6a5275bde0e6bf20ef4b91bfc32ed57c0552e2e8e15463372b17a"

    patch do
      url "https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-1.1.1f-sess_set_get_cb_yield.patch"
      sha256 "d289aa9464552f8caf19de01732ad06832f5f7decaaa4a1eb8c3034ed8a155eb"
    end
  end

  keg_only "only for use with OpenResty"

  # Only needs 5.10 to run, but needs >5.13.4 to run the testsuite.
  # https://github.com/openssl/openssl/blob/4b16fa791d3ad8/README.PERL
  # The MacOS ML tag is same hack as the way we handle most :python deps.
  depends_on "perl" if build.with?("test") && MacOS.version <= :mountain_lion

  # SSLv2 died with 1.1.0, so no-ssl2 no longer required.
  # SSLv3 & zlib are off by default with 1.1.0 but this may not
  # be obvious to everyone, so explicitly state it for now to
  # help debug inevitable breakage.
  def configure_args; %W[
    --prefix=#{prefix}
    --openssldir=#{openssldir}
    --libdir=lib
    no-threads
    shared
    zlib
    -g
    enable-ssl3
    enable-ssl3-method
  ]
  end

  def install
    # This could interfere with how we expect OpenSSL to build.
    ENV.delete("OPENSSL_LOCAL_CONFIG_DIR")

    # This ensures where Homebrew's Perl is needed the Cellar path isn't
    # hardcoded into OpenSSL's scripts, causing them to break every Perl update.
    # Whilst our env points to opt_bin, by default OpenSSL resolves the symlink.
    if which("perl") == Formula["perl"].opt_bin/"perl"
      ENV["PERL"] = Formula["perl"].opt_bin/"perl"
    end

    arch_args = []
    if OS.mac?
      arch_args += %W[darwin64-#{Hardware::CPU.arch}-cc enable-ec_nistp_64_gcc_128]
    elsif Hardware::CPU.intel?
      arch_args << (Hardware::CPU.is_64_bit? ? "linux-x86_64" : "linux-elf")
    elsif Hardware::CPU.arm?
      arch_args << (Hardware::CPU.is_64_bit? ? "linux-aarch64" : "linux-armv4")
    end

    #ENV.deparallelize
    system "perl", "./Configure", *(configure_args + arch_args)
    system "make"
    system "make", "test" if build.with?("test")
    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
  end

  def openssldir
    etc/"openssl@1.1.1"
  end
end
