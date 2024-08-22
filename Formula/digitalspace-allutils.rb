class DigitalspaceAllutils < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"
  revision 106

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/digitalspace-allutils"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "728bc25029ba13a4a6e795d35a8f37f2053573a1eeab9ed1cf8841070a025fa2"
    sha256 cellar: :any_skip_relocation, monterey:       "e38b4f08d600d9b95ce5c8439005ab75d35580d43deaf37d61c4839afd7df589"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "5df74ee3af3aeb38b5ea64ad0818e17702c44163f7d08825428556cd2ecf86de"
  end

  depends_on "coreutils"
  depends_on "moreutils"
  depends_on "gettext"
  depends_on "htop"
  depends_on "jq"
  depends_on "pv"
  depends_on "jenv"
  depends_on "nvm"
  depends_on "vim"
  depends_on "watch"

  on_macos do 
    depends_on "flock"
  end

  # on_linux do
  #   depends_on "util-linux"
  # end

  def install
    (buildpath / "keepme.txt").write("")
    prefix.install "keepme.txt"
  end
end