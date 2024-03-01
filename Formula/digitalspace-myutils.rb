class DigitalspaceMyutils < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.0"

  depends_on "coreutils"
  depends_on "moreutils"
  depends_on "gettext"
  depends_on "mtr"
  depends_on "htop"
  depends_on "jq"
  depends_on "yq"
  depends_on "pv"
  depends_on "s3cmd"
  depends_on "jenv"
  depends_on "nvm"
  

  def install
    (buildpath / ".keepme").write("")
    prefix.install ".keepme"
  end
end