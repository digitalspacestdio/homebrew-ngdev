# PHP - Homebrew Development Environment
LEMP (NGINX/PHP/MySql) Development Environment

Supported OS: **macOS** (Intel, Apple Silicon), **Linux** (x86_64), **Windows 10/11** (x86_64) over WSL2  
Supported PHP: **8.3**, **8.2**, **8.1**, **8.0**, **7.4**, **7.3**, **7.2**, **7.1**, **7.0**, **5.6**  
Supported CMS and Frameworks: **Symfony**, **Laravel**, **Yii v1/v2**, **Magento v1/v2**, **OroCommerce/OroCRM/OroPlatform**, **AkeneoPIM**, **Wordpress**, and more

## Installation
### 1. Install Base Tools
- Macos: `xcode-select --install`
- Linux (Debian based): `sudo apt install -yq curl git patch systemtap-sdt-dev python3 build-essential tar`
- Linux (OpenSUSE 15+): `sudo zypper install curl git patch systemtap-sdt-devel python3 tar` or `sudo transactional-update pkg install curl git patch systemtap-sdt-devel python3 gcc tar`
- Windows (10/11): Enable WSL with supported system and follow related steps
### 2. Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
```bash
BREW_BIN=$(find /opt/homebrew/bin /usr/local/bin /home/linuxbrew/.linuxbrew/bin -name "brew" 2> /dev/null); [ -f "${BREW_BIN}" ] \
&& (echo; echo 'eval "$('${BREW_BIN}' shellenv)"') | tee -a $HOME/.zprofile | tee -a $HOME/.bashrc \
&& eval "$(${BREW_BIN} shellenv)"
```

### 3. Add Homebrew Taps
```bash
brew tap digitalspacestdio/nextgen-devenv
brew tap digitalspacestdio/php
```

### 4. Install Base Packages
```bash
brew install digitalspace-supervisor digitalspace-nginx digitalspace-traefik digitalspace-dnsmasq
```

### 5. Install PHP
You need to install at least one
```bash
brew install php82-common php74-common php56-common
```
> select any of version you need just by changing the name to `phpXX-common`, where XX is the first two numbers of the php version without dots
> available versions (mac: intel, arm64; linux: x86_64): `8.3`, `8.2`, `8.1`, `8.0`, `7.4`, `7.3`, `7.2`, `7.1`, `7.0`, `5.6`

### 6. Install Composer (optional)
```bash
brew install composer@2
```
### 7. Install Databases (optional)

MySQL 8.0
```bash
brew install digitalspace-mysql80
```

PostgreSQL 15
```bash
brew install digitalspace-postgresql15
```

### 8. Install Root SSL Certificate
#### Macos
```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $(brew --prefix)/etc/openssl/localCA/root_ca.crt
```

#### Linux / Windows WSL (Ubuntu)
```bash
sudo mkdir /usr/local/share/ca-certificates/extra
sudo cp $(brew --prefix)/etc/openssl/localCA/root_ca.crt /usr/local/share/ca-certificates/extra/
sudo dpkg-reconfigure ca-certificates
sudo update-ca-certificates
```

> If you want re-generate the root certificate you need to remove certificates folder by following command: `rm -rf $(brew --prefix)/etc/openssl/localCA`
> and resinstall the `digitalspace-local-ca` formula: `brew uninstall --ignore-dependencies digitalspace-local-ca && brew install digitalspace-local-ca`

### 9. Enable and Start Dnsmasq Service
```bash
digitalspace-dnsmasq-start
```

### 10. Enable and Start Supervisor Service
```bash
digitalspace-supervisor-start
```

### 11. Verify that Supervisor Services Started Successfully
```bash
digitalspace-supctl status
```
### 12. Create an Example Project and Test it

Create the new project dir in following path: `~/www/dev/hello/%2nd_level_domain%/%3rd_level_domain%`
```bash
mkdir -p ~/www/dev/hello
```
> By default dns and web-server configured for domains in the `.dev.local` pool 

Create index.php
```bash
echo '<?php phpinfo();' > ~/www/dev/hello/index.php
```

Opein `https://hello.dev.local/` in your browser and check the result.

