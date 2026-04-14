---
name: biome-plugins-setup
description: Configuring @aliou/biome-plugins in a project's biome.json. Use when adding, removing, or configuring Biome GritQL plugins from this package in a consumer project. Covers plugin registration, file scoping with includes, and troubleshooting.
---

# Biome Plugins Setup

This skill covers how to configure plugins from `@aliou/biome-plugins` in a consumer project's `biome.json`.

## Available plugins

| Plugin | File | Description |
|---|---|---|
| `no-inline-imports` | `no-inline-imports.grit` | Disallows `await import()` and `require()` inside functions. |
| `no-interpolated-classname` | `no-interpolated-classname.grit` | Disallows template literals in `className`. Use `cn()` instead. |
| `phosphor-icon-suffix` | `phosphor-icon-suffix.grit` | Phosphor icon imports must end with `Icon` suffix. |
| `no-js-import-extension` | `no-js-import-extension.grit` | Disallows `.js` extensions in import paths. |
| `no-ts-import-extension` | `no-ts-import-extension.grit` | Disallows `.ts` extensions in import paths. |
| `no-emojis` | `no-emojis.grit` | Disallows emoji characters in code. |
| `no-inner-types` | `no-inner-types.grit` | Disallows type/interface declarations inside functions. |
| `pi-no-node-exec` | `pi-no-node-exec.grit` | Disallows `child_process` imports in pi extensions. |
| `no-buried-await` | `no-buried-await.grit` | Disallows burying `await` inside parentheses or call arguments. |
| `no-empty-catch` | `no-empty-catch.grit` | Disallows empty `catch` blocks (comments alone don't count). |

## Installation

```bash
npm install --save-dev @aliou/biome-plugins
# or
pnpm add -D @aliou/biome-plugins
bun add -d @aliou/biome-plugins
```

## Basic configuration

Add plugin paths to the `plugins` array in `biome.json`. Paths are relative to the `biome.json` file and must point into `node_modules`:

```json
{
  "plugins": [
    "./node_modules/@aliou/biome-plugins/plugins/no-empty-catch.grit",
    "./node_modules/@aliou/biome-plugins/plugins/no-emojis.grit"
  ]
}
```

Pick only the plugins you need. Each plugin is standalone.

## File scoping with includes

Plugin entries can be objects with `path` and `includes` for per-plugin file scoping. Use an object with `path` and `includes` instead of a plain string:

```json
{
  "plugins": [
    {
      "path": "./node_modules/@aliou/biome-plugins/plugins/pi-no-node-exec.grit",
      "includes": ["extensions/**/*.ts"]
    },
    {
      "path": "./node_modules/@aliou/biome-plugins/plugins/no-emojis.grit",
      "includes": ["src/**/*.tsx", "!**/*.test.tsx"]
    }
  ]
}
```

### Includes syntax

- Glob patterns match relative to the `biome.json` file.
- `**` matches all files and subfolders recursively.
- `*` matches zero or more characters in a single path segment.
- Patterns starting with `!` are exclusions (negated globs).
- Negated patterns exclude matches.
- Without `includes`, the plugin runs on all files the linter processes.
- Plugin `includes` can narrow scope, not expand it beyond what Biome is already linting.

### Includes examples

Only TypeScript files in `src/`:
```json
{ "path": "./node_modules/@aliou/biome-plugins/plugins/no-inner-types.grit", "includes": ["src/**/*.ts"] }
```

All JS/TS/JSX/TSX source files except tests:
```json
{ "path": "./node_modules/@aliou/biome-plugins/plugins/no-emojis.grit", "includes": ["src/**/*.{js,jsx,ts,tsx}", "!**/*.test.*"] }
```

Specific directory with an exception:
```json
{ "path": "./node_modules/@aliou/biome-plugins/plugins/no-js-import-extension.grit", "includes": ["src/**/*.ts", "!src/legacy/**"] }
```

## Mixing plain strings and objects

Both formats can coexist in the same `plugins` array:

```json
{
  "plugins": [
    "./node_modules/@aliou/biome-plugins/plugins/no-empty-catch.grit",
    {
      "path": "./node_modules/@aliou/biome-plugins/plugins/pi-no-node-exec.grit",
      "includes": ["extensions/**/*.ts"]
    }
  ]
}
```

## Combining with linter.includes

`linter.includes` controls which files the linter processes overall. Plugin `includes` are applied on top of that -- a file must be matched by both `linter.includes` (or `files.includes`) and the plugin's `includes` to be processed by that plugin.

If a file is excluded by `linter.includes`, adding it to a plugin's `includes` will not bring it back.

If your `biome.json` lives in a subpackage (monorepo), all plugin paths must still be relative to that `biome.json` file.

## Verifying setup

Run `biome lint` on a file that should trigger the plugin:

```bash
npx biome lint src/example.tsx
```

Plugin diagnostics appear with the `plugin` category in the output.

## Common issues

- **No diagnostics from plugin**: Check the plugin path is correct and relative to `biome.json`. Check `linter.enabled` is not `false`. Check `includes` patterns match the target files.
- **Plugin running on wrong files**: Add `includes` with glob patterns to scope the plugin. Use negated patterns (`!`) for exclusions.
- **Biome version too old for includes**: The object format `{ "path": ..., "includes": [...] }` requires Biome >= 2.5. This package's peer dependency enforces this.
