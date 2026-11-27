# Bidirekt Homebrew tap

Homebrew formulas for [Bidirekt](https://bidirekt.com): the `bidirekt` CLI and the self-hosted broker.

```
brew tap bidirekt/tap
brew trust bidirekt/tap
brew install bidirekt
```

## The broker

```
brew install bidirekt-broker
createdb bidirekt
brew services start bidirekt-broker
```

The first start writes the broker's settings, with a generated token signing key, to `$(brew --prefix)/etc/bidirekt/broker.env`: the database (`postgres://localhost:5432/bidirekt`), and `http://localhost:8080` as the address. Edit it and run `brew services restart bidirekt-broker` to change them. Open http://localhost:8080 to create the admin.

The broker migrates its database when it starts. After `brew upgrade bidirekt-broker`, run `brew services restart bidirekt-broker`.

## How the formulas are updated

`scripts/update.py` renders `Formula/` from `templates/` with the latest release of each repository and its `checksums.txt`. The `Update formulas` workflow runs it every hour and commits any change.
