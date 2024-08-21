class DigitalspaceAllutils < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"
  revision 106

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