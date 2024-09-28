class DigitalspaceAllutils < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"
  revision 110

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/110/digitalspace-allutils"
    sha256 cellar: :any_skip_relocation, ventura:      "a477976003591e00b79a10a870c10d4cb601e0083173d8ed5065604cd8eaf4f1"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e458f84c020af4b70ff63f4a6593f8f503ead595d6caa152a1c0e7ad54af7f7a"
  end

  depends_on "coreutils"
  depends_on "moreutils"
  depends_on "gettext"
  depends_on "htop"
  depends_on "jq"
  depends_on "pv"
  depends_on "jenv"
  depends_on "vim"
  depends_on "watch"
  depends_on "flock"
  

  def install
    (buildpath / "keepme.txt").write("")
    prefix.install "keepme.txt"
  end
end
