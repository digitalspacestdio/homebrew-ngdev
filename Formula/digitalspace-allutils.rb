class DigitalspaceAllutils < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"
  revision 110

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/110/digitalspace-allutils"
    sha256 cellar: :any_skip_relocation, ventura:      "ddee04999d95e61b6a0d9b6d6808ae35bf794f95580c72b80a7bac2a6914f486"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "dea0c8ebbb5a3c832b860eb0406e1739df0a7476175528b08c148eddbe8aa26c"
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
