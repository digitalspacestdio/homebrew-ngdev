class DigitalspaceWebpConvert < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.10"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/nextgen-devenv/digitalspace-webp-convert"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "b56a0cc3d42789c012c3527b01ef05e7d9c5e47be0ed523f9096977d51bae5df"
    sha256 cellar: :any_skip_relocation, sonoma:        "b736c23d10637b160013f2791f9c2f9f3cda62b1cd65b8b663ea8b928f5b68e3"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "66393ef896527a2fbda32c7b38a6b3dceb2f84760cae8be87c13b895113351ec"
  end

  depends_on 'webp'
  depends_on 'rush-parallel'

  def webp_convert_script
    <<~EOS
    #/bin/bash
    set -e
    FIND_ARGS=()
    FIND_MAXDEPTH=1
    CWEBP_ARGS=()
    
    while [[ $# -gt 0 ]]
    do
        key="$1"
        case $key in
            --debug)
            set -x
            shift # past argument
            ;;
            --maxdepth)
            FIND_MAXDEPTH=$2
            shift # past argument
            shift # past value
            ;;
            --recursive)
            FIND_MAXDEPTH=0
            shift # past argument
            ;;
            *)    # unknown option
            CWEBP_ARGS+=("$1")
            shift # past argument
            ;;
        esac
    done
    
    if [[ $FIND_MAXDEPTH -gt 0 ]]; then
        FIND_ARGS+=("-maxdepth $FIND_MAXDEPTH")
    fi
    
    find . ${FIND_ARGS[*]} -type f -name '*.jpeg' \\
    -o -name '*.jpg' \\
    -o -name '*.png' \\
    -o -name '*.gif' \\
    -o -name '*.tif' \\
    -o -name '*.tiff' \\
    -o -name '*.pgm' \\
    -o -name '*.ppm' \\
    -o -name '*.pnm' \\
    | rush --verbose 'cwebp -m 6 -q 51 -af -progress ${CWEBP_ARGS[*]} "{}" -o "{.}.webp"'
    EOS
  rescue StandardError
      nil
  end

  def install
    (buildpath / "bin" / "webp-convert").write(webp_convert_script)
    (buildpath / "bin" / "webp-convert").chmod(0755)
    bin.install "bin/webp-convert"
  end
end