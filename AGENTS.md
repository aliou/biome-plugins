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

- `engine biome(1.0)` tells Biome this is a Biome-compatible GritQL pattern.
- `language` sets the target language. Use `js`, `js(jsx)`, `js(typescript)`, `js(typescript,jsx)`, or `css`. Only JavaScript and CSS are supported.

After the headers, the file contains one or more patterns with conditions and diagnostic registration.

## Plugin API

Biome extends GritQL with one function:

- `register_diagnostic(span, message, severity)` -- registers a diagnostic when the pattern matches.
  - `span` (required): the AST node to underline in the diagnostic output.
  - `message` (required): the message to display.
  - `severity` (optional): `"error"` (default), `"warn"`, `"info"`, or `"hint"`.

## Key GritQL concepts

- **Code snippets**: backtick-wrapped source code that matches structurally (ignoring formatting). Example: `` `console.log($msg)` ``
- **Metavariables**: `$name` captures an AST node. `$_` is a wildcard. Same variable used twice must match the same code.
- **Match operator** (`<:`): tests if a variable matches a pattern. Example: `$method <: "log"`
- **`contains`**: searches descendants for a pattern.
- **`or { ... }`**: matches any of several patterns.
- **`not`**: negates a condition.
- **Regex**: `r"pattern"` for regex matching against captured text.
- **Named nodes**: Biome AST node types in PascalCase (e.g. `JsTemplateExpression`, `JsxAttribute`, `JsIfStatement`). Discover them via the [Biome Playground](https://biomejs.dev/playground/) syntax tree view.

## References

- Official docs: https://biomejs.dev/linter/plugins
- GritQL reference: https://biomejs.dev/reference/gritql
- GritQL language docs: https://docs.grit.io/language/overview
- Plugin distribution discussion: https://github.com/biomejs/biome/discussions/6265
- Feature tracking: https://github.com/biomejs/biome/issues/2582

## Repository layout

```
plugins/           -- GritQL plugin files (.grit)
tests/fail/        -- Fixture files that must trigger diagnostics
tests/pass/        -- Fixture files that must pass cleanly
scripts/test.sh    -- Test runner (pnpm test)
README.md          -- Usage instructions for consumers
AGENTS.md          -- This file (context for coding agents)
```

## Plugins

| Plugin | Description |
|---|---|
| `no-inline-imports` | Disallows `await import()` and `require()` inside functions. All imports should be static at the top of the file. |
| `no-interpolated-classname` | Disallows template literals in `className` attributes. Enforces using a `cn()` utility instead. |
| `phosphor-icon-suffix` | Enforces that Phosphor icon imports end with the `Icon` suffix (e.g. `HouseIcon`, not `House`). |
| `no-js-import-extension` | Disallows `.js` extensions in import and re-export paths. The fix is to remove the extension and set `moduleResolution: "bundler"` in tsconfig.json. |
| `no-emojis` | Disallows emoji characters in string literals, template literals, and JSX text. |
| `no-inner-types` | Disallows TypeScript `type` and `interface` declarations inside function bodies. |
