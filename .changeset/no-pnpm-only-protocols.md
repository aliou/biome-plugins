---
"@aliou/biome-plugins": minor
---

Add `no-pnpm-only-protocols` to the `pi` preset. Flags `catalog:`, `workspace:`, `link:`, `portal:`, and `patch:` dependency specs in JSON files, which npm rejects with EUNSUPPORTEDPROTOCOL. This breaks npm-based installs of git checkouts, such as pi's `git:` package installs.
