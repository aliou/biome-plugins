# biome-plugins

`@aliou/biome-plugins` is a published npm package of GritQL lint rules, presets, and shared Biome configs. Many repositories extend its configs, so a rule, preset, or config change alters their lint results on the next install.

## Commands

- Run everything inside `nix develop`. It provides node and pnpm and installs the pre-commit hooks (`biome check --write`, lockfile check, `pnpm test`).
- `pnpm test` runs `scripts/test.sh`. It lints fixtures with `tests/plugins.json` and installs the package into a scratch project to test the manifest, presets, and configs.
- The root `biome.json` only checks this repository's own files. Do not add plugins to it.

## Invariants

- Rule names are the `.grit` file stems and appear in suppressions as `lint/plugin/@aliou/biome-plugins/<name>`. Renaming a rule is a breaking change.
- Every `.grit` file needs an entry in `biome-manifest.json`, fixtures in `tests/fail/` and `tests/pass/`, and a `scripts/test.sh` call that asserts the exact diagnostic count.
- Presets must not share rules. Biome reports a rule twice when two enabled entries include it.
- Configs reference presets with `"resolutionKind": "config"` so they resolve from the package, not the consuming project.
- Fixtures contain no comments unless the comment is what the rule tests.

## Documentation triggers

- Rule, preset, or config changes: update the tables in `README.md` and `skills/setting-up-biome-plugins/SKILL.md`.
- New GritQL engine behavior or gotchas: update `skills/writing-gritql-plugins/SKILL.md`.

## Pointers

- Before writing or debugging a `.grit` file, read `skills/writing-gritql-plugins/SKILL.md`.
- Before adding a changeset, read `.pi/skills/biome-plugins-changesets/SKILL.md`.
