# biome-plugins

Custom Biome lint rules written as GritQL plugins, plus shared Biome configs that enable them. Requires Biome 2.6 or later.

## Install

```bash
pnpm add -D @biomejs/biome @aliou/biome-plugins
```

## Use a config

A config sets formatter, linter, and plugin defaults. Extend one in `biome.json` and keep only project-specific settings:

```json
{
  "extends": ["@aliou/biome-plugins/configs/base"],
  "files": { "includes": ["**/*.ts", "**/*.json"] }
}
```

| Config | Contents |
|---|---|
| `configs/base` | Git ignore file, 2-space indent, Biome's recommended rules, organize imports, and the `recommended` preset. Skips `.pi/` and `.agents/`, does not format Markdown, `pnpm-lock.yaml`, or `pnpm-workspace.yaml`. |
| `configs/strict` | `base` plus the `strict` preset. |
| `configs/pi` | `base` plus the `pi` preset. |

Configs can be combined: `"extends": ["@aliou/biome-plugins/configs/strict", "@aliou/biome-plugins/configs/pi"]`.

## Use plugins directly

Enable presets or single rules in `plugins`:

```json
{
  "plugins": [
    "@aliou/biome-plugins/presets/recommended",
    "@aliou/biome-plugins/no-homedir"
  ]
}
```

Presets do not overlap. Stack them on top of `recommended`.

| Preset | Rules |
|---|---|
| `presets/recommended` | `no-buried-await`, `no-emojis`, `no-empty-catch`, `no-inline-imports`, `no-inner-types`, `no-is-record`, `no-js-import-extension`, `no-ts-import-extension` |
| `presets/strict` | `no-chained-type-assertions`, `no-conditional-empty-object-spread`, `no-reflect-apply`, `no-reflect-get` |
| `presets/schema` | `no-unknown-parameters`, `no-unknown-returns`, `no-unsafe-dictionary-type` |
| `presets/pi` | `no-unimported-text`, `pi-no-node-exec` |
| `presets/react` | `no-interpolated-classname` |

To scope a rule or preset to some files, use the object form:

```json
{
  "plugins": [
    { "path": "@aliou/biome-plugins/presets/schema", "includes": ["src/api/**"] }
  ]
}
```

Run `biome inspect plugins` to list the enabled rules and the preset each comes from.

## Suppress a diagnostic

Use the package-qualified rule name, or `lint/plugin` to suppress any plugin:

```ts
// biome-ignore lint/plugin/@aliou/biome-plugins/no-homedir: resolves the config directory
```

## Rules

All rules report errors, except `no-left-border-accent`, which warns.

| Rule | Description |
|---|---|
| `no-buried-await` | Disallows `await` inside parentheses or call arguments. Await the value first, then use it. |
| `no-chained-type-assertions` | Disallows chained type assertions such as `x as unknown as User`, except chains made only of `as const`. |
| `no-conditional-empty-object-spread` | Disallows spreading a conditional with `{}` on one branch, such as `{ ...(cond ? { x } : {}) }`. |
| `no-emojis` | Disallows emoji in string literals, template literals, and JSX text. |
| `no-empty-catch` | Disallows `catch` blocks that are empty or contain only comments. |
| `no-homedir` | Disallows importing `homedir` or `userInfo` from `os` and reading `process.env.HOME`. |
| `no-inline-imports` | Disallows `await import()` and `require()` inside functions, and `import()` types anywhere. |
| `no-inner-types` | Disallows `type` and `interface` declarations inside function bodies. |
| `no-interpolated-classname` | Disallows template literals in `className`. Use a `cn()` helper. |
| `no-is-record` | Disallows `isRecord` helper functions. |
| `no-js-import-extension` | Disallows `.js` extensions in import and export paths. Unsafe fix removes the extension. |
| `no-left-border-accent` | Disallows `border-left` accent stripes on non-`blockquote` boxes in CSS. |
| `no-reflect-apply` | Disallows `Reflect.apply()`. |
| `no-reflect-get` | Disallows `Reflect.get()`. |
| `no-runtime-typeof` | Disallows `typeof` checks. Parse input with a schema at the boundary. |
| `no-ts-import-extension` | Disallows `.ts` extensions in import and export paths. Unsafe fix removes the extension. |
| `no-unimported-text` | Requires every `Text` reference to come from an import, so the DOM `Text` global is never used by accident. |
| `no-unknown-parameters` | Disallows parameters typed `unknown`, except one named `cause`. |
| `no-unknown-returns` | Disallows `unknown`, `Promise<unknown>`, and `PromiseLike<unknown>` return types. |
| `no-unsafe-dictionary-type` | Disallows `Record<string, unknown \| any \| object \| {}>` and equivalent index signatures. |
| `phosphor-icon-suffix` | Requires Phosphor icon imports to end with `Icon`. |
| `pi-no-node-exec` | Disallows `child_process` in [pi](https://pi.dev) extensions. Use `pi.exec()`. |

The fixes for the import extension rules need `moduleResolution: "bundler"` in `tsconfig.json`. Apply them with `biome lint --write --unsafe`.

## Limitations

GritQL has no scope analysis or type information. The `schema` rules match syntax only: they do not resolve type aliases and cannot tell a real parsing boundary from an `unknown` escape hatch. Scope them with `includes` to adopt them gradually.

## Development

```bash
nix develop
pnpm install
pnpm test
```
