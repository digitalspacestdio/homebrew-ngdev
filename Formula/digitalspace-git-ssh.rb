class DigitalspaceGitSsh < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.2.1"
  revision 106

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/digitalspace-git-ssh"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "d9bedebf068c63df94c51185cd1e9d9e261f670ce57bb894164de70150a43e93"
    sha256 cellar: :any_skip_relocation, monterey:       "098c7e4ea28969a091c8f75e46321163d147cd85ee79023c6dd60877714af019"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "7c97356bb5b0a8024f68e37ad3cae0624c6a2c5e15fc0f880c93bafc3ae7b927"
  end

  def git_ssh_gen_script
    <<~EOS
    #!/bin/bash
    if [[ -z $1 ]] || [[ -z $2 ]]; then
      echo "Usage: $0 <hostname> <organisation> [repository]
      echo "Example: $0 github.com facebook react
      exit 1
    fi
    
    REPO_HOST_NAME=$1
    REPO_GROUP_NAME=$2
    REPO_GROUP_NAME_LOWER=$(echo $REPO_GROUP_NAME | awk '{print tolower($0)}')
    REPO_NAME=$3
    REPO_NAME_LOWER=$(echo $REPO_NAME | awk '{print tolower($0)}')

    if [[ -z $REPO_NAME ]]; then
      OUTPUT_FILE_NAME=$HOME/.ssh/id_rsa_${REPO_HOST_NAME}_${REPO_GROUP_NAME_LOWER}
    else 
      OUTPUT_FILE_NAME=$HOME/.ssh/id_rsa_${REPO_HOST_NAME}_${REPO_GROUP_NAME_LOWER}_${REPO_NAME_LOWER}
    fi

    ssh-keygen -f "${OUTPUT_FILE_NAME}"
    
    EOS
  rescue StandardError
      nil
  end

  def git_ssh_script
    <<~EOS
    #!/bin/bash
    SSH_KEY_ARG=""
    if echo $@ | grep -i '[A-Za-z0-9_\\-]\\+@[A-Za-z0-9_\\-\\.]\\+' > /dev/null; then
      REPO_HOST_NAME=$(echo $@ | awk '{print tolower($0)}' | grep -o '[A-Za-z0-9_\\-]\\+@[A-Za-z0-9_\\-\\.]\\+' | grep -o '[A-Za-z0-9_\\-\\.]\\+$' | sed "s/[^[:alnum:]-]/_/g")
      REPO_GROUP_NAME=$(echo "${@: -1}" | grep -o '[A-Za-z0-9_-]\\+/[A-Za-z0-9_-]\\+' | awk -F\\/ '{ print $1 }' | sed "s/[^[:alnum:].-]/_/g")
      REPO_GROUP_NAME_LOWER=$(echo $REPO_GROUP_NAME | awk '{print tolower($0)}')
      REPO_NAME=$(echo "${@: -1}" | grep -o '[A-Za-z0-9_-]\\+/[A-Za-z0-9_-]\\+' | awk -F\\/ '{ print $2 }' | sed "s/[^[:alnum:].-]/_/g")
      REPO_NAME_LOWER=$(echo $REPO_NAME | awk '{print tolower($0)}')
      if [[ -f $HOME/.ssh/id_rsa_${REPO_HOST_NAME}_${REPO_GROUP_NAME}_${REPO_NAME} ]]; then
        SSH_KEY_ARG="-i $HOME/.ssh/id_rsa_${REPO_HOST_NAME}_${REPO_GROUP_NAME}_${REPO_NAME} -o IdentitiesOnly=yes";
      elif [[ -f $HOME/.ssh/id_rsa_${REPO_HOST_NAME}_${REPO_GROUP_NAME} ]]; then
        SSH_KEY_ARG="-i $HOME/.ssh/id_rsa_${REPO_HOST_NAME}_${REPO_GROUP_NAME} -o IdentitiesOnly=yes";
      elif [[ -f $HOME/.ssh/id_rsa_${REPO_HOST_NAME}_${REPO_GROUP_NAME_LOWER}_${REPO_NAME_LOWER} ]]; then
        SSH_KEY_ARG="-i $HOME/.ssh/id_rsa_${REPO_HOST_NAME}_${REPO_GROUP_NAME_LOWER}_${REPO_NAME_LOWER} -o IdentitiesOnly=yes";
      elif [[ -f $HOME/.ssh/id_rsa_${REPO_HOST_NAME}_${REPO_GROUP_NAME_LOWER} ]]; then
        SSH_KEY_ARG="-i $HOME/.ssh/id_rsa_${REPO_HOST_NAME}_${REPO_GROUP_NAME_LOWER} -o IdentitiesOnly=yes";
      fi
    fi

    if [[ $SSH_KEY_ARG != "" ]]; then
        >&2 echo "[git-ssh] Additional arguments will be used: $SSH_KEY_ARG"
    fi

    exec ssh $SSH_KEY_ARG "$@"
    EOS
  rescue StandardError
      nil
  end

  def install
    (buildpath / "bin" / "git-ssh").write(git_ssh_script)
    (buildpath / "bin" / "git-ssh").chmod(0755)
    bin.install "bin/git-ssh"

    (buildpath / "bin" / "git-ssh-gen").write(git_ssh_gen_script)
    (buildpath / "bin" / "git-ssh-gen").chmod(0755)
    bin.install "bin/git-ssh-gen"
  end

end
