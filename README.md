# Homebrew Nextgen Devenv

### Installation

1. Add the homebrew tap
```bash
brew tap digitalspacestdio/nextgen-devenv
```

2. Install formulas
```bash
brew install digitalspace-dnsmasq digitalspace-nginx digitalspace-traefik digitalspace-supervisor
```

3. Enable the dnsmasq service
```bash
sudo digitalspace-dnsmasq-start
```

5. Generate new CA certificates
```bash
digitalspace-traefik-step-ca-init
```

4. Start the supervisor
```bash
brew services start digitalspace-supervisor
```
