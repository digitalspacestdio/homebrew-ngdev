class DigitalspaceWebpConvert < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.10"
  revision 107

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/107/digitalspace-webp-convert"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9fe04a17530a5129a2551bfb900d6a8e677c06c5215bc369d25eb51781b70eb3"
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