# Agent Instructions for digitalspacestdio/ngdev

Homebrew tap that packages a local PHP/web development stack: NGINX, Traefik,
dnsmasq, Supervisor, databases (MySQL, PostgreSQL, Redis, OpenSearch), and
supporting utilities. PHP itself lives in the separate `digitalspacestdio/php`
tap.

Supported platforms: macOS (Intel / Apple Silicon), Linux (x86_64 /
aarch64), Windows 10/11 via WSL2.

## Commands

Use `brew` from the user's Homebrew installation (e.g. `$(brew --prefix)/bin/brew`),
not a system `brew` on `PATH`.

```bash
brew tap digitalspacestdio/ngdev
brew tap digitalspacestdio/php   # required for PHP-FPM integration
```

Before committing formula changes, verify locally:

```bash
brew audit --strict --online Formula/digitalspace-<name>.rb
brew install --build-from-source digitalspace-<name>
brew test digitalspace-<name>
```

For style checks on Ruby formulas:

```bash
brew style --fix Formula/digitalspace-<name>.rb
```

## Repository Layout

- `Formula/` — Homebrew formulas (`digitalspace-*.rb`)
- `bin/_ngdev-bottles-make.sh` — build bottles for tap formulas
- `bin/_ngdev-bottles-upload.sh` — upload bottles to R2 and commit bottle blocks
- `README.md` — user-facing install and usage guide

## Naming Conventions

| Item | Pattern | Example |
|------|---------|---------|
| Formula file | `digitalspace-<name>.rb` | `digitalspace-nginx.rb` |
| Class name | `Digitalspace<Name>` (CamelCase) | `DigitalspaceNginx` |
| Binary | `digitalspace-<service>` | `digitalspace-nginx` |
| Config dir | `$(brew --prefix)/etc/digitalspace-<service>/` | `etc/digitalspace-nginx/` |
| Logs | `$(brew --prefix)/var/log/digitalspace-<service>/` | `var/log/digitalspace-nginx/` |
| Runtime | `$(brew --prefix)/var/run/digitalspace-<service>/` | `var/run/digitalspace-nginx/` |
| Supervisor | `etc/digitalspace-supervisor.d/<service>.ini` | `nginx.ini`, `mysql80.ini` |

Versioned formulas use `@` in the name (`digitalspace-mysql@8.0`) with a
wrapper formula without `@` (`digitalspace-mysql80`) that wires up config,
supervisor, and helper scripts.

## Architecture

```
Browser → Traefik (:443) → NGINX (:1984) → PHP-FPM (unix socket)
                ↑
           dnsmasq (*.dev.local, *.docker.local)
                ↑
           Supervisor (manages all services)
```

- Default docroot: `~/www/<pool>/<project>/` (e.g. `~/www/dev/hello/`)
- Default domain pool: `.dev.local`
- NGINX selects PHP version from `.phprc`, `.php-version`, or global config
- `digitalspace-local-ca` provides a self-signed root CA for HTTPS

## Formula Patterns

### Bottles

All formulas share a unified `revision` (currently `111`). Bottle `root_url`
follows this pattern:

```
https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/ngdev/<revision>/<formula-name>
```

Supported bottle tags: `arm64_ventura`, `ventura`, `x86_64_linux`.

When changing a formula in a way that affects the binary, bump `revision` in
**all** affected formulas and rebuild bottles with `bin/_ngdev-bottles-make.sh`.

### Environment Variables

Services expose listen address/port via `HOMEBREW_NGDEV_*` env vars:

| Variable | Default | Service |
|----------|---------|---------|
| `HOMEBREW_NGDEV_NGINX_LISTEN_ADDRESS` | `127.0.0.1` | NGINX |
| `HOMEBREW_NGDEV_NGINX_LISTEN_PORT` | `1984` | NGINX |
| `HOMEBREW_NGDEV_MYSQL80_LISTEN_ADDRESS` | `127.0.0.1` | MySQL 8.0 |
| `HOMEBREW_NGDEV_MYSQL80_LISTEN_PORT` | `3306` | MySQL 8.0 |

Follow the same pattern when adding new services.

### post_install

- Write config files to `etc/digitalspace-<service>/` only if they do not
  already exist (preserve user customizations).
- Register services in `etc/digitalspace-supervisor.d/*.ini`.
- On macOS use `sed -i ''`; on Linux use `sed -i` (see `digitalspace-nginx.rb`).
- Replace `/var/www` with `$HOME/www` in generated configs.

### Service Integration

Long-running services use two mechanisms:

1. Homebrew `service` blocks (LaunchAgent / systemd user services)
2. Supervisor configs dropped into `etc/digitalspace-supervisor.d/`

Helper scripts follow the naming pattern `digitalspace-<service>-start`,
`digitalspace-<service>-stop`, etc.

### Meta / Wrapper Formulas

Some formulas are thin wrappers with `url "file:///dev/null"` that depend on
the real build formula and add config, scripts, and supervisor integration
(e.g. `digitalspace-mysql80` → `digitalspace-mysql@8.0`).

### Dependencies Between Tap Formulas

Internal dependencies omit the tap prefix when both formulas are in this tap
(e.g. `depends_on "digitalspace-nginx-lua-module"`). Cross-tap deps use the
full tap path (e.g. `depends_on "digitalspacestdio/common/icu4c@74.2"`).

## Bottle Workflow

```bash
# Build bottles (optionally pass formula names as arguments)
REBUILD=1 bin/_ngdev-bottles-make.sh digitalspace-nginx

# Upload to R2 and commit updated bottle blocks (requires s3cmd credentials)
bin/_ngdev-bottles-upload.sh digitalspace-nginx
```

The make script stores artifacts in `~/.bottles/<formula>.bottle/`. The upload
script merges bottle JSON per platform and auto-commits with message
`bottle <formula> <ostype>`.

## Guidelines

1. Keep diffs minimal; match existing formula style and structure.
2. Do not rename binaries or config paths without a strong reason — users and
   other formulas depend on them.
3. Preserve user-edited configs in `post_install` (check `File.exist?` before
   writing).
4. Test on both macOS and Linux when changing `post_install` or service scripts.
5. When bumping upstream versions, update `url`, `sha256`, and rebuild bottles.
6. Do not use conventional commit prefixes (`feat:`, `fix:`, etc.).
7. Keep comments minimal; prefer self-documenting code.
8. User-facing docs belong in `README.md`, not in formula comments.

## Common Tasks

### Add a new service formula

1. Create `Formula/digitalspace-<name>.rb` following an existing service
   (e.g. `digitalspace-redis.rb`).
2. Add supervisor config in `post_install`.
3. Add `revision`, `bottle` block with correct `root_url`.
4. Run `brew audit --strict --online` and `brew install --build-from-source`.
5. Build and upload bottles.

### Bump NGINX or module versions

1. Update `url` / `sha256` in `digitalspace-nginx.rb`.
2. Check dependent module formulas (`digitalspace-nginx-lua-module`,
   `digitalspace-ngx-devel-kit`, `digitalspace-openresty`).
3. Rebuild all affected bottles.

### Update bottle revision globally

When bottle infrastructure changes, bump `revision` in every formula and
rebuild all bottles:

```bash
REBUILD=1 bin/_ngdev-bottles-make.sh
```
