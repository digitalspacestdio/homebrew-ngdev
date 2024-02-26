# Homebrew Nextgen Devenv
macOS/Linux/Windows 10 LEMP (NGINX/PHP/MySql) Development Environment



### Installation
0. Install Homebrew by following official guide [https://brew.sh/](https://brew.sh/)

1. Add the homebrew taps
```bash
brew tap digitalspacestdio/nextgen-devenv
brew tap digitalspacestdio/php
```


2. Install base packages
```bash
brew install digitalspace-dnsmasq digitalspace-nginx digitalspace-traefik digitalspace-supervisor
```
3. Install mysql (optional)
```bash
brew install digitalspace-mysql80
```
4. Install PHPs (optional)
```bash
brew install php83-common php82-common php74-common
```
> you can select only the formulas you need

5. Install the root certificat to the system
```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $(brew --prefix)/etc/openssl/localCa/root_ca.crt
```
> If you want re-generate the root certificate you need to remove certificates folder by following command: `rm -rf $(brew --prefix)/etc/openssl/localCA`
> and resinstall the `digitalspace-local-ca` formula: `brew uninstall --ignore-dependencies digitalspace-local-ca && brew install digitalspace-local-ca`

6. Enable the dnsmasq service
```bash
sudo $(which digitalspace-dnsmasq-start)
```

7. Start the supervisor
```bash
sudo $(which digitalspace-supervisor-start)
```

8. Check the services status
```bash
digitalspace-supctl
```
9. Create your first project

Create the project dir
```bash
mkdir -p ~/www/dev/hello
```

Create index.php
```bash
echo '<?php phpinfo();' > ~/www/dev/hello/index.php
```

Opein in browser `https://hello.dev.local/`

