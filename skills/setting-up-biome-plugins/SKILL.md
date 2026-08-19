---
name: setting-up-biome-plugins
description: Adopting @aliou/biome-plugins in a consumer project. Use when adding, removing, or scoping Biome GritQL plugins from this package in a project's biome.json. Covers auditing the codebase for violations, choosing relevant plugins, registration with includes scoping, and verifying the setup.
---

# Setting Up Biome Plugins

This skill covers how to adopt plugins from `@aliou/biome-plugins` in a consumer project: audit first, pick only relevant plugins, register them in `biome.json`, and verify they fire.

## Step 1: Audit before enabling

Enable a plugin because it fires on real code in the project, not by default. Before adding it:

- **Grep for the pattern** it bans. Zero hits means the plugin adds nothing today -- skip it or accept it as a guardrail, knowingly.
- **Or run a trial lint**: register the plugin temporarily and run `biome lint` to count diagnostics. Many hits means fix the code (or scope with `includes`) before committing to the plugin, or the change drowns in errors.

Example greps:

```bash
grep -rn "await import(\|require(" src/          # no-inline-imports
grep -rn "process.env.HOME\|from \"os\"" src/    # no-homedir
grep -rn "@phosphor-icons/react" src/            # phosphor-icon-suffix (any hits at all?)
```

If a plugin's subject does not exist in the codebase (no Phosphor imports, no `child_process`), do not register it.

## Step 2: Pick relevant plugins

| Plugin | Description | Applies when |
|---|---|---|
| `no-inline-imports` | Disallows `await import()` and `require()` inside functions. | Any JS/TS project standardizing on static imports. |
| `no-interpolated-classname` | Disallows template literals in `className`. Use `cn()` instead. | Frontend projects that have a `cn()` utility (clsx/tailwind-merge). |
| `phosphor-icon-suffix` | Phosphor icon imports must end with the `Icon` suffix. | Frontend projects using `@phosphor-icons/react`. |
| `no-js-import-extension` | Disallows `.js` extensions in import and re-export paths. | TypeScript projects using `moduleResolution: "bundler"` in tsconfig.json. |
| `no-ts-import-extension` | Disallows `.ts` extensions in import and re-export paths. | TypeScript projects using `moduleResolution: "bundler"` in tsconfig.json. |
| `no-emojis` | Disallows emoji characters in string literals, template literals, and JSX text. | Any project adopting a no-emoji writing convention. |
| `no-inner-types` | Disallows `type`/`interface` declarations inside function bodies. | TypeScript projects. |
| `pi-no-node-exec` | Disallows `child_process` imports; use `pi.exec()` from the ExtensionAPI instead. | [pi](https://pi.dev) extension projects only. |
| `no-buried-await` | Disallows burying `await` inside parentheses or call arguments. | Async TypeScript projects. |
| `no-empty-catch` | Disallows empty `catch` blocks (comments alone don't count). | Any project. |
| `no-homedir` | Disallows `os.homedir`/`os.userInfo` imports and `process.env.HOME`; use a configured paths utility instead. | Projects that have a paths utility to point to. |
| `no-is-record` | Disallows `isRecord()` helper functions. | TypeScript projects validating objects with explicit types or schemas. |
| `no-unimported-text` | Requires `Text` references to have a runtime import binding. | Projects rendering a `Text` component from a TUI library (pi/ink). Guards against the DOM `Text` global. |

All plugins register diagnostics with severity `error`.

## Step 3: Install

```bash
npm install --save-dev @aliou/biome-plugins
# or
pnpm add -D @aliou/biome-plugins
bun add -d @aliou/biome-plugins
```

## Step 4: Register in biome.json

Add plugin paths to the `plugins` array. Paths are relative to the `biome.json` file and must point into `node_modules`:

```json
{
  "plugins": [
    "./node_modules/@aliou/biome-plugins/plugins/no-empty-catch.grit",
    "./node_modules/@aliou/biome-plugins/plugins/no-emojis.grit"
  ]
}
```

Pick only the plugins you need. Each plugin is standalone.

### File scoping with includes

Plugin entries can be objects with `path` and `includes` to scope a plugin to specific files. The object format requires Biome >= 2.5:

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

Includes syntax:

- Glob patterns match relative to the `biome.json` file.
- `**` matches all files and subfolders recursively; `*` matches within a single path segment.
- Patterns starting with `!` are exclusions.
- Without `includes`, the plugin runs on all files the linter processes. `includes` can narrow scope, not expand it beyond what Biome is already linting.

String and object entries can coexist in the same array:

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

`linter.includes` (or `files.includes`) still controls which files the linter processes overall; a file must pass both to be linted by a given plugin. If a file is excluded by `linter.includes`, a plugin's `includes` cannot bring it back.

In a monorepo, plugin paths are relative to the `biome.json` that declares them.

## Step 5: Verify

Run `biome lint` on a file that should trigger:

```bash
npx biome lint src/example.tsx
```

Plugin diagnostics appear with the `plugin` category in the output. Then run it on a clean file and confirm no diagnostics. Suppression comments use the `plugin` category: `// biome-ignore lint/plugin: reason`.

## Common issues

- **No diagnostics from a plugin**: Check the path is correct and relative to `biome.json`. Check `linter.enabled` is not `false`. Check `includes` patterns match the target files.
- **Plugin running on wrong files**: Add `includes` with glob patterns to scope it; use negated patterns (`!`) for exclusions.
- **Biome version too old for includes**: The object format `{ "path": ..., "includes": [...] }` requires Biome >= 2.5.
