class DigitalspaceAllutils < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"
  revision 106

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/digitalspacestdio/ngdev/digitalspace-allutils"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "078eb33749aa635fa242d1a4ef1abea2e0c253aa82bef036fac9b4db245cf487"
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