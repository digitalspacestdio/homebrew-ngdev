# Homebrew based Development Environment
`NGINX`/`PHP`/`MySQL`/`PgSQL`/`Redis`/`Mailhog`

Tested on **macOS** (`Intel` / `Apple Silicon`), **Linux** (`x86_64` / `aarch64`) / **Windows 10/11** (`x86_64`) over *WSL*  
Supported CMS and Frameworks: **Symfony**, **Laravel**, **Yii v1/v2**, **Magento v1/v2**, **OroCommerce/OroCRM/OroPlatform**, **AkeneoPIM**, **Wordpress**, and more

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

### 1. Add Homebrew Taps
```bash
brew tap digitalspacestdio/ngdev
```
```bash
brew tap digitalspacestdio/php
```

### 2. Install Base Packages
```bash
brew install digitalspace-supervisor digitalspace-nginx digitalspace-traefik digitalspace-dnsmasq
```

### 3. Install needed PHP versions
You need to install at least one
```bash
brew install php84-common php74-common php56-common
```
> select any of version you need just by changing the name to `phpXX-common`, where XX is the first two numbers of the php version without dots
> available versions: `8.4`, `8.3`, `8.2`, `8.1`, `8.0`, `7.4`, `7.3`, `7.2`, `7.1`, `7.0`, `5.6`

### 4. Install Composer (optional)
```bash
brew install composer@2
```
### 4. Install Databases (optional)

PostgreSQL 15
```bash
brew install digitalspace-postgresql15
```

MySQL 8.0
```bash
brew install digitalspace-mysql80
```

MySQL 5.7
```bash
brew install digitalspace-mysql57
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

### 6. Enable/Start Dnsmasq Service
```bash
digitalspace-dnsmasq-start
```

### 7. Enable/Start Supervisor Service
```bash
digitalspace-supervisor-start
```

### 8. Verify that Supervisor Services Started Successfully
```bash
digitalspace-supctl status
```
### 9. Creating an Example Project

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

