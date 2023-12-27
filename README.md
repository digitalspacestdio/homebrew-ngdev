# Homebrew Nextgen Devenv

### Installation

1. Add the homebrew tapы
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
brew install php83-common php82-common php81-common php74-common php73-common php72-common php71-common
```
> you can select only the formulas you need

5. Install the root certificat to the system
```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $(brew --prefix)/etc/openssl/localCa/root_ca.crt
```

6. Enable the dnsmasq service
```bash
sudo digitalspace-dnsmasq-start
```

7. Start the supervisor
```bash
sudo digitalspace-supervisor-start
```

8. Check the services status
```bash
digitalspace-supctl
```

