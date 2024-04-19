class DigitalspaceAllutils < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.1"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/nextgen-devenv/digitalspace-allutils"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "766a8010f4243840fa6b9450dee9fa8df8d73cc9fb297178897a6d84ded509b3"
  end

  depends_on "coreutils"
  depends_on "moreutils"
  depends_on "gettext"
  depends_on "gnu-tar"
  depends_on "mtr"
  depends_on "htop"
  depends_on "jq"
  depends_on "yq"
  depends_on "pv"
  depends_on "s3cmd"
  depends_on "jenv"
  depends_on "vim"
  

  def install
    (buildpath / "keepme.txt").write("")
    prefix.install "keepme.txt"
  end
end
