# PHP - Homebrew Development Environment
LEMP (NGINX/PHP/MySql) Development Environment

Supported OS: **macOS** (Intel, Apple Silicon), **Linux** (x86_64), **Windows 10/11** (x86_64) over WSL2  
Supported PHP: **8.3**, **8.2**, **8.1**, **8.0**, **7.4**, **7.3**, **7.2**, **7.1**, **7.0**, **5.6**  
Supported CMS and Frameworks: **Symfony**, **Laravel**, **Yii v1/v2**, **Magento v1/v2**, **OroCommerce/OroCRM/OroPlatform**, **AkeneoPIM**, **Wordpress**

## Installation
### 0. Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
```bash
BREW_BIN=$(find /opt/homebrew/bin /usr/local/bin /home/linuxbrew/.linuxbrew/bin -name "brew" 2> /dev/null); [ -f "${BREW_BIN}" ] \
&& (echo; echo 'eval "$('${BREW_BIN}' shellenv)"') | tee -a $HOME/.zprofile | tee -a $HOME/.bashrc \
&& eval "$(${BREW_BIN} shellenv)"
```

### 1. Add the homebrew taps
```bash
brew tap digitalspacestdio/nextgen-devenv
```
```bash
brew tap digitalspacestdio/php
```

### 2. Install Base Packages
```bash
brew install digitalspace-supervisor digitalspace-nginx digitalspace-traefik digitalspace-dnsmasq
```

### 3. Install Needed PHP Versions (optional)
```bash
brew install php82-common php74-common php56-common
```
> you can select any of version you need just by changing the name to `phpXX-common`, where XX is the first two numbers of the php version without dots
> next versions available (mac: intel, arm64; linux: x86_64): `8.3`, `8.2`, `8.1`, `8.0`, `7.4`, `7.3`, `7.2`, `7.1`, `7.0`, `5.6`

### 4. Install Composer  (optional)
```bash
brew install composer@2
```
### 4. Install Databases (optional)

MySQL 8.0
```bash
brew install digitalspace-mysql80
```

PostgreSQL 15
```bash
brew install digitalspace-postgresql15
```

### 5. Install Root SSL Certificate
#### Macos
```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $(brew --prefix)/etc/openssl/localCA/root_ca.crt
```

#### Linux / Windows WSL - Ubuntu (22.04)
```bash
sudo mkdir /usr/local/share/ca-certificates/extra
sudo cp $(brew --prefix)/etc/openssl/localCA/root_ca.crt /usr/local/share/ca-certificates/extra/
sudo dpkg-reconfigure ca-certificates
sudo update-ca-certificates
```

> If you want re-generate the root certificate you need to remove certificates folder by following command: `rm -rf $(brew --prefix)/etc/openssl/localCA`
> and resinstall the `digitalspace-local-ca` formula: `brew uninstall --ignore-dependencies digitalspace-local-ca && brew install digitalspace-local-ca`

### 6. Enable and Start Dnsmasq Service
```bash
digitalspace-dnsmasq-start
```

### 7. Enable and Start Supervisor Service
```bash
digitalspace-supervisor-start
```

### 8. Verify that Supervisor Services Started Successfully
```bash
digitalspace-supctl status
```
### 9. Creating an Example Project

Create the project dir
```bash
mkdir -p ~/www/dev/hello
```

Create index.php
```bash
echo '<?php phpinfo();' > ~/www/dev/hello/index.php
```

Opein in browser `https://hello.dev.local/`

