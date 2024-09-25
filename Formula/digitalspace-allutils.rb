class DigitalspaceAllutils < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"
  revision 109

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/107/digitalspace-allutils"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "905c1acd17316169b7dff894887591c6adb98ff313c9ea95daf6e9c6c1f4c68d"
    sha256 cellar: :any_skip_relocation, monterey:       "e26ffd6880fe5eba27310b19ac059dad7e55d9f4f40172edcafb70226b0acaf4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "5695362b6886457f1a1477a07c3d313ea9d93cd8814339332759f8f6e8b0fa3c"
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
