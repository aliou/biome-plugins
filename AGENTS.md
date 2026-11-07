# biome-plugins

`@aliou/biome-plugins` is a published npm package of GritQL lint rules, presets, and shared Biome configs. Many repositories extend its configs, so a rule, preset, or config change alters their lint results on the next install.

## Commands

- `pnpm test` runs `scripts/test.sh`. It lints the fixtures in `tests/fail/` and `tests/pass/` through `tests/plugins.json` — one fail fixture per rule, asserting the exact diagnostic message and count — then packs the tarball into a scratch project and tests the manifest, presets, and configs as npm would install them.
- The root `biome.json` only checks this repository's own files. Do not add plugins to it.

## Invariants

- Rule names are the `.grit` file stems and appear in suppressions as `lint/plugin/@aliou/biome-plugins/<name>`.
- Every `.grit` file needs an entry in `biome-manifest.json`, fixtures in `tests/fail/` and `tests/pass/`, and a `scripts/test.sh` call that asserts the exact diagnostic count.
- Presets must not share rules. Biome reports a rule twice when two enabled entries include it.
- Configs reference presets with `"resolutionKind": "config"` so they resolve from the package, not the consuming project.
- Fixtures contain no comments unless the comment is what the rule tests.

## Documentation triggers

- Preset or config changes: update the config and preset tables in `README.md` and `skills/setting-up-biome-plugins/SKILL.md`.
- New GritQL engine behavior or gotchas: update `skills/writing-gritql-plugins/SKILL.md`.

## Pointers

- Before writing or debugging a `.grit` file, read `skills/writing-gritql-plugins/SKILL.md`.

## Changesets

Every change to a plugin, preset, or config that will be published needs a changeset file in `.changeset/`, committed with the change. Releases go through the GitHub Actions release PR on main.
