---
name: setting-up-biome-plugins
description: Adopts @aliou/biome-plugins in a project's biome.json. Use when extending its shared configs, enabling its presets or rules, scoping them to files, migrating from ./node_modules/.../*.grit plugin paths, or rewriting its suppression comments. Requires Biome 2.6 or later.
---

# Setting up @aliou/biome-plugins

## Install

```bash
pnpm add -D @biomejs/biome@^2.6 @aliou/biome-plugins
```

## Choose a config

Start from a config and keep only project-specific settings in `biome.json`:

```json
{
  "extends": ["@aliou/biome-plugins/configs/base"],
  "files": { "includes": ["**/*.ts", "**/*.json"] }
}
```

| Config | Use when |
|---|---|
| `configs/base` | Any TypeScript project. Git ignore file, 2-space indent, Biome recommended rules, organize imports, `presets/recommended`. Skips `.pi/` and `.agents/`. Does not format Markdown or pnpm-managed YAML. |
| `configs/strict` | `base` plus `presets/strict`. New projects. |
| `configs/pi` | `base` plus `presets/pi`. [pi](https://pi.dev) extensions and packages. |

Configs combine: `"extends": ["@aliou/biome-plugins/configs/strict", "@aliou/biome-plugins/configs/pi"]`.

Do not repeat settings the config already sets. Keep the project's own `files.includes`, rule overrides, and `overrides`.

## Add presets or rules

Add entries to `plugins` on top of a config, or without one:

```json
{
  "plugins": [
    "@aliou/biome-plugins/presets/schema",
    "@aliou/biome-plugins/no-homedir"
  ]
}
```

| Entry | Rules | Use when |
|---|---|---|
| `presets/recommended` | `no-buried-await`, `no-emojis`, `no-empty-catch`, `no-inline-imports`, `no-inner-types`, `no-is-record`, `no-js-import-extension`, `no-ts-import-extension` | Any TypeScript project with `moduleResolution: "bundler"`. |
| `presets/strict` | `no-chained-type-assertions`, `no-conditional-empty-object-spread`, `no-reflect-apply`, `no-reflect-get` | Projects that reject type escape hatches. |
| `presets/schema` | `no-unknown-parameters`, `no-unknown-returns`, `no-unsafe-dictionary-type` | Projects that parse all external input with a schema library. |
| `presets/pi` | `no-unimported-text`, `pi-no-node-exec` | pi extensions. |
| `presets/react` | `no-interpolated-classname` | React projects with a `cn()` helper. |
| `no-homedir` | | Projects with a paths utility to point to. |
| `no-runtime-typeof` | | Projects that parse input with a schema at I/O boundaries. |
| `phosphor-icon-suffix` | | Projects importing `@phosphor-icons/react`. |
| `no-left-border-accent` | | CSS projects. |

Presets do not overlap, so stacking them never reports a rule twice. Do not also list a rule that an enabled preset includes: Biome reports it twice.

Before enabling `strict`, `schema`, or a single rule in an existing project, run a trial lint and count the diagnostics. Many hits means fix the code first or scope the entry with `includes`. Skip rules whose subject does not exist in the project, such as `phosphor-icon-suffix` without Phosphor imports.

## Scope to files

Use the object form. Globs match relative to the `biome.json` that declares them:

```json
{
  "plugins": [
    { "path": "@aliou/biome-plugins/presets/schema", "includes": ["src/api/**"] }
  ]
}
```

`includes` narrows the files a plugin runs on. It cannot add files that `files.includes` or `linter.includes` exclude.

## Migrate from .grit paths

Projects set up before Biome 2.6 list files such as `./node_modules/@aliou/biome-plugins/plugins/no-emojis.grit`.

1. Replace the `plugins` list with a config in `extends`, or with presets and rules. Remove every `.grit` path: a rule loaded through a path and through a preset reports twice.
2. Remove settings the config already sets.
3. Rewrite suppressions. `lint/plugin/<name>` does not match rules loaded through the package:

   ```bash
   rg -l 'biome-ignore(-all|-start|-end)? lint/plugin/[a-z-]+' --glob '!node_modules' | while read -r f; do
     perl -pi -e 's#(biome-ignore(?:-all|-start|-end)? lint/plugin/)(?!@)([a-z-]+)#$1\@aliou/biome-plugins/$2#g' "$f"
   done
   ```

   `lint/plugin` without a rule name still suppresses every plugin.

## Verify

```bash
biome inspect plugins   # enabled rules and the preset each comes from
biome inspect config    # resolved settings and where each comes from
biome check .
```

Biome reports an unused suppression as `suppressions/unused`. Treat it as a missed rewrite.
