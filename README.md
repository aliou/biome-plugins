# biome-plugins

Custom Biome lint rules written as GritQL plugins.

## Plugins

| Plugin | Description |
|---|---|
| `no-inline-imports` | Disallows `await import()` and `require()` inside functions. All imports should be static `import` statements at the top of the file. |
| `no-interpolated-classname` | Disallows template literals in `className` attributes. Enforces using a `cn()` utility instead. |
| `phosphor-icon-suffix` | Enforces that Phosphor icon imports end with the `Icon` suffix (e.g. `HouseIcon`, not `House`). |
| `no-js-import-extension` | Disallows `.js` extensions in import and re-export paths. Use `moduleResolution: "bundler"` in tsconfig.json instead. |
| `no-ts-import-extension` | Disallows `.ts` extensions in import and re-export paths. Use `moduleResolution: "bundler"` in tsconfig.json instead. |
| `no-emojis` | Disallows emoji characters in string literals, template literals, and JSX text. |
| `no-inner-types` | Disallows TypeScript `type` and `interface` declarations inside function bodies. |
| `pi-no-node-exec` | Disallows importing from `child_process` / `node:child_process` in [pi](https://pi.dev) extensions. Use `pi.exec()` from the ExtensionAPI instead. |
| `no-buried-await` | Disallows burying `await` inside parentheses or call arguments. Await the value first, then use it in a separate expression. |
| `no-empty-catch` | Disallows empty `catch` blocks. Catch blocks must contain actual code, not only comments. |
| `no-homedir` | Disallows importing `os.homedir`/`os.userInfo` and reading `process.env.HOME`. Use a configured paths utility instead. |
| `no-is-record` | Disallows creating `isRecord` function helpers. Use explicit types or schema-specific validation instead. |
| `no-unimported-text` | Requires `Text` references, including type annotations, `new Text()`, and `<Text>`, to have a runtime import binding. Prevents accidental use of the DOM `Text` global. |
| `no-chained-type-assertions` | Disallows chained `as`/angle-bracket type assertions (e.g. `x as unknown as User`), except chains made only of `as const`. |
| `no-conditional-empty-object-spread` | Disallows spreading a conditional that uses `{}` on one branch to omit fields (e.g. `{ ...(cond ? { x } : {}) }`). |
| `no-reflect-apply` | Disallows `Reflect.apply()`. Call the typed function directly or model dynamic dispatch behind a named interface. |
| `no-reflect-get` | Disallows `Reflect.get()`. Use typed property access, or parse dynamic input into a named domain type first. |
| `no-runtime-typeof` | Disallows `typeof` checks. Parse input with a schema at its I/O boundary instead of narrowing ad hoc. |
| `no-unknown-parameters` | Disallows function parameters typed `unknown`, except a parameter named `cause`. |
| `no-unknown-returns` | Disallows function return types of `unknown`, `Promise<unknown>`, or `PromiseLike<unknown>`. |
| `no-unsafe-dictionary-type` | Disallows dictionary types with unsafe values: `Record<string, unknown/any/object/{}>` and equivalent index signatures. |

## Usage

### 1. Install

```bash
npm install --save-dev @aliou/biome-plugins
```

Or with any other package manager:

```bash
pnpm add -D @aliou/biome-plugins
bun add -d @aliou/biome-plugins
```

### 2. Configure

Reference the plugins you want in your `biome.json` using relative paths to `node_modules`:

```json
{
  "plugins": [
    "./node_modules/@aliou/biome-plugins/plugins/no-interpolated-classname.grit",
    "./node_modules/@aliou/biome-plugins/plugins/phosphor-icon-suffix.grit"
  ]
}
```

Pick only the ones you need -- each plugin is a standalone `.grit` file, and several only apply to specific stacks (for example `phosphor-icon-suffix` only in projects using Phosphor icons, `pi-no-node-exec` only in [pi](https://pi.dev) extension projects). Audit your codebase first: register a plugin because it fires on real code, not by default.

To scope a plugin to specific files, use the object form with `includes` globs (requires Biome >= 2.5):

```json
{
  "plugins": [
    {
      "path": "./node_modules/@aliou/biome-plugins/plugins/pi-no-node-exec.grit",
      "includes": ["extensions/**/*.ts"]
    }
  ]
}
```

### 3. Run

Plugin diagnostics show up when running `biome lint` or `biome check` as usual:

```bash
biome check .
```

To suppress a plugin diagnostic, use a suppression comment with the `plugin` category: `// biome-ignore lint/plugin: reason`.

## Limitations

Biome's plugin system is still experimental. There is no automatic npm package resolution for plugins -- you must use explicit relative paths to `node_modules` as shown above.

See [biomejs/biome#6265](https://github.com/biomejs/biome/discussions/6265) for the ongoing discussion on plugin distribution.

GritQL has no scope analysis, no cross-statement dataflow, and no access to type-alias environments. The schema-boundary plugins (`no-runtime-typeof`, `no-unknown-parameters`, `no-unknown-returns`, `no-unsafe-dictionary-type`) match direct syntactic forms only -- they don't resolve local type aliases, and they don't distinguish `unknown`/`Record<string, unknown>` used as a genuine parsing boundary from the same types used as an escape hatch. Adopt them per file or per package with the `includes` option if you want to migrate incrementally.
