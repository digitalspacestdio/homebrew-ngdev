class DigitalspaceAllutils < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"
  revision 109

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/109/digitalspace-allutils"
    sha256 cellar: :any_skip_relocation, ventura:      "1352316fc00ea86e0957561c1cbeb31ec3152ab2677d1da68edc7b745feda3dd"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ae444b46f5aa1cf45695e8b4f19761d8fe38dd4b6a6005877f58d3f124be0905"
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
