# Homebrew Nextgen Devenv
macOS/Linux/Windows 10 LEMP (NGINX/PHP/MySql) Development Environment



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


### 2. Install base packages
```bash
brew install digitalspace-dnsmasq digitalspace-nginx digitalspace-traefik digitalspace-supervisor
```
### 3. Install mysql (optional)
```bash
brew install digitalspace-mysql80
```
### 4. Install PHPs (optional)
```bash
brew install php83-common php82-common php74-common
```
> you can select only the formulas you need

### 5. Install the root certificat to the system
#### Macos
```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $(brew --prefix)/etc/openssl/localCa/root_ca.crt
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

### 6. Enable the dnsmasq service
```bash
sudo $(which digitalspace-dnsmasq-start)
```

### 7. Start the supervisor
```bash
digitalspace-supervisor-start
```

### 8. Check the services status
```bash
digitalspace-supctl status
```
### 9. Create your first project

Create the project dir
```bash
mkdir -p ~/www/dev/hello
```

Create index.php
```bash
echo '<?php phpinfo();' > ~/www/dev/hello/index.php
```

Opein in browser `https://hello.dev.local/`

