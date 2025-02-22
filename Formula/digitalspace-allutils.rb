class DigitalspaceAllutils < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"
  revision 111

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/111/digitalspace-allutils"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "5c42b62930ab843a24f1baa46943748e835161c0da31690fd18f026f368a5ce6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "fbbf3163ae147e6a5bc3c612047b99be496d049d88c3432088abc12c4d4e8ba8"
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
