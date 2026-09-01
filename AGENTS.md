# Biome GritQL Plugins

This repository contains custom Biome lint rules written as GritQL plugins.

## What are GritQL plugins?

GritQL is a structural pattern matching language that operates on the AST (abstract syntax tree), not on raw text. Biome uses GritQL to let you write custom lint rules as `.grit` files that match code patterns and emit diagnostics.

A plugin is a `.grit` file that:
1. Declares an engine and target language
2. Defines a structural pattern to match against source code
3. Calls `register_diagnostic()` to emit an error, warning, or hint when the pattern matches

Plugins are registered in `biome.json` under the `plugins` array and run alongside built-in rules during `biome lint` or `biome check`.

## Plugin structure

Every `.grit` file starts with two required headers:

```grit
engine biome(1.0)
language js(jsx)
```

- `engine biome(1.0)` tells GritQL to use Biome's syntax tree (not Tree-sitter's).
- `language` sets the target language. Use `js`, `js(jsx)`, `js(typescript)`, `js(typescript,jsx)`, `css`, or `json`. JavaScript, CSS, and JSON are supported.

After the headers, the file contains one or more patterns with conditions and diagnostic registration.

## Plugin API

Biome extends GritQL with one function:

- `register_diagnostic(span, message, severity, fix_kind)` -- registers a diagnostic when the pattern matches.
  - `span` (required): the AST node to underline in the diagnostic output.
  - `message` (required): the message to display.
  - `severity` (optional): `"error"` (default), `"warn"`, `"info"`, or `"hint"`.
  - `fix_kind` (optional): `"safe"` or `"unsafe"` (default). Only relevant when the pattern also registers a rewrite with `=>`. Safe rewrites apply with `biome check --write`; unsafe rewrites require `--write --unsafe`.

Plugins can also register code fixes with the rewrite operator `` $node => `replacement` `` inside a `where` block. The replacement must be built structurally from captured metavariables. Biome's Grit engine supports no `let` bindings and no string functions (`replace`, `substring`, ...), and metavariables inside string literals never match, so fixes that require computing a new string (for example stripping a `.js` suffix from an import path) cannot be expressed today.

Plugin diagnostics can be suppressed with `// biome-ignore lint/plugin: reason` comments.

## Plugin configuration

In `biome.json`, a plugin entry is either a path string or an object:

```json
{
  "plugins": [
    "./plugins/no-emojis.grit",
    { "path": "./plugins/pi-no-node-exec.grit", "includes": ["extensions/**/*.ts"] }
  ]
}
```

`includes` takes glob patterns (negated with `!`) and scopes the plugin to matching files (Biome >= 2.5).

There is no way to pass options or variables into a `.grit` file -- no severity override, no banned-name lists, nothing. Values must be hardcoded in the pattern (see [biomejs/biome#10928](https://github.com/biomejs/biome/issues/10928)). To approximate per-project configuration, fork the `.grit` file or generate it from a template.

## Key GritQL concepts

- **Code snippets**: backtick-wrapped source code that matches structurally (ignoring formatting). Example: `` `console.log($msg)` ``
- **Metavariables**: `$name` captures an AST node. `$_` is a wildcard. `$...` is the spread metavariable (matches zero or more arguments). Same variable used twice must match the same code.
- **Match operator** (`<:`): tests if a variable matches a pattern. Example: `$method <: "log"`
- **`contains`**: searches descendants for a pattern.
- **`or { ... }`**: matches any of several patterns. Unify arms with the same `as $match` variable so a shared `where` clause can reference them.
- **`not`**: negates a condition.
- **Regex**: `r"pattern"` for regex matching against captured text (full node text, including quotes).
- **Named nodes**: Biome AST node types in PascalCase (e.g. `JsTemplateExpression`, `JsxAttribute`, `JsIfStatement`), with nested field matching for structural constraints (e.g. `JsCatchClause(body = JsBlockStatement(statements = []))`). Discover them via the [Biome Playground](https://biomejs.dev/playground/) Syntax tab.

See the `writing-gritql-plugins` and `setting-up-biome-plugins` skills under `skills/` for authoring and adoption workflows.

## References

- Official docs: https://biomejs.dev/linter/plugins
- Plugin recipes: https://biomejs.dev/recipes/gritql-plugins
- GritQL reference: https://biomejs.dev/reference/gritql
- GritQL language docs: https://docs.grit.io/language/overview
- Plugin distribution discussion: https://github.com/biomejs/biome/discussions/6265
- Plugins RFC (GritQL + JS/TS plugins): https://github.com/biomejs/biome/discussions/1762
- Feature tracking: https://github.com/biomejs/biome/issues/2582

## Repository layout

```
plugins/           -- GritQL plugin files (.grit)
tests/fail/        -- Fixture files that must trigger diagnostics
tests/pass/        -- Fixture files that must pass cleanly
scripts/test.sh    -- Test runner (pnpm test)
README.md          -- Usage instructions for consumers
AGENTS.md          -- This file (context for coding agents)
skills/            -- Agent skills (writing-gritql-plugins, setting-up-biome-plugins)
```

## Plugins

| Plugin | Description |
|---|---|
| `no-inline-imports` | Disallows `await import()` and `require()` inside functions. All imports should be static at the top of the file. |
| `no-interpolated-classname` | Disallows template literals in `className` attributes. Enforces using a `cn()` utility instead. |
| `phosphor-icon-suffix` | Enforces that Phosphor icon imports end with the `Icon` suffix (e.g. `HouseIcon`, not `House`). |
| `no-js-import-extension` | Disallows `.js` extensions in import and re-export paths. The fix is to remove the extension and set `moduleResolution: "bundler"` in tsconfig.json. |
| `no-ts-import-extension` | Disallows `.ts` extensions in import and re-export paths. The fix is to remove the extension and set `moduleResolution: "bundler"` in tsconfig.json. |
| `no-emojis` | Disallows emoji characters in string literals, template literals, and JSX text. |
| `no-inner-types` | Disallows TypeScript `type` and `interface` declarations inside function bodies. |
| `pi-no-node-exec` | Disallows importing from `child_process` / `node:child_process`. Use `pi.exec()` from the ExtensionAPI instead. |
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
| `no-left-border-accent` | Disallows `border-left` used as an ad-hoc accent stripe on non-`blockquote` boxes, and `border-left-width` overrides that thicken one side of a full `border`. Exempts `blockquote`, triangle/arrow shapes, and zero-width resets. Targets CSS (`.css` files and `<style>` blocks in HTML). |
