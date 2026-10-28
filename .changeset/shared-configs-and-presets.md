---
"@aliou/biome-plugins": minor
---

Publish rules, presets, and shared configs through a Biome manifest. Requires Biome 2.6.

- Extend `@aliou/biome-plugins/configs/base`, `configs/strict`, or `configs/pi` for formatter, linter, and plugin defaults.
- Enable `@aliou/biome-plugins/presets/<name>` (`recommended`, `strict`, `schema`, `pi`, `react`) or `@aliou/biome-plugins/<rule>` in `plugins`.
- Rules loaded through the package are suppressed with `lint/plugin/@aliou/biome-plugins/<rule>`. `lint/plugin/<rule>` only matches rules loaded from a `.grit` path.
- `phosphor-icon-suffix`, `no-homedir`, and `pi-no-node-exec` report every matching specifier in an import, including aliases.
- `no-js-import-extension` and `no-ts-import-extension` have an unsafe fix that removes the extension.
- `no-left-border-accent` no longer flags rules that also set `border-right`.
