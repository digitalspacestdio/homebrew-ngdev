class DigitalspaceAllutils < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"
  revision 107

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/digitalspace-allutils"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c822d3cd2e640617b9510f023c51a2e0f13877477bf61c7c1273377c16fa1ecb"
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
