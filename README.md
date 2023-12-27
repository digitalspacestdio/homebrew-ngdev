# Homebrew Nextgen Devenv

### Installation

1. Add the homebrew tapы
```bash
brew tap digitalspacestdio/nextgen-devenv
brew tap digitalspacestdio/php
```


2. Install formulas
```bash
brew install digitalspace-dnsmasq digitalspace-nginx digitalspace-traefik digitalspace-supervisor
```
```bash
brew install php83-common php82-common php81-common php74-common
```

3. Install the root certificat to the system
```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $(brew --prefix)/etc/openssl/localCa/root_ca.crt
```

4. Enable the dnsmasq service
```bash
sudo digitalspace-dnsmasq-start
```

5. Start the supervisor
```bash
sudo digitalspace-supervisor-start
```
