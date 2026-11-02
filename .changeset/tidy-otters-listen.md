---
"@aliou/biome-plugins": minor
---

Add `no-pi-tui-truncate` and include it in the `pi` preset. Disallows `truncateToWidth` from `@earendil-works/pi-tui`, which injects reset sequences that break caller styling and mis-parses non-SGR escape sequences.
