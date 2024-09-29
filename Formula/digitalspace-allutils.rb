class DigitalspaceAllutils < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"
  revision 110

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/110/digitalspace-allutils"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "90ad1251ca7dfefad1b1d25b78613d22ea0a5a8d6e978dc39ab9cd1f5f62647b"
    sha256 cellar: :any_skip_relocation, ventura:       "a477976003591e00b79a10a870c10d4cb601e0083173d8ed5065604cd8eaf4f1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "e458f84c020af4b70ff63f4a6593f8f503ead595d6caa152a1c0e7ad54af7f7a"
    sha256 cellar: :any_skip_relocation, aarch64_linux: "6a2024d67594c9bc5165c04d3acaf54d9d10f16895204a6e668d6599eebd016b"
  end

  depends_on "coreutils"
  depends_on "moreutils"
  depends_on "gettext"
  depends_on "jq"
  depends_on "pv"
  depends_on "jenv"
  depends_on "watch"
  on_macos do
    depends_on "flock"
  end

  def install
    (buildpath / "keepme.txt").write("")
    prefix.install "keepme.txt"
  end
end
