---
name: biome-gritql-plugins
description: Writing custom Biome lint rules as GritQL plugins. Use when creating, editing, or debugging .grit files for Biome's plugin system. Covers GritQL pattern syntax, AST node matching, metavariables, the register_diagnostic API, and testing patterns.
---

# Biome GritQL Plugins

GritQL is a structural pattern matching language that operates on Biome's AST. Each plugin is a `.grit` file that matches code patterns and emits diagnostics.

## File structure

Every `.grit` file requires two headers:

```grit
engine biome(1.0)
language js(jsx)
```

Supported language values: `js`, `js(jsx)`, `js(typescript)`, `js(typescript,jsx)`, `css`.

After headers, write one pattern with conditions and a `register_diagnostic()` call.

## Plugin API

One function is available:

```grit
register_diagnostic(
    span = $node,        -- required: AST node to underline
    message = "...",     -- required: diagnostic message
    severity = "error"   -- optional: error (default), warn, info, hint
)
```

## Pattern syntax

### Code snippets

Backtick-wrapped code matches structurally (ignores formatting, quote style, whitespace):

```grit
`console.log($msg)`
```

### Metavariables

- `$name` captures an AST node
- `$_` is a wildcard (match but don't capture)
- Same variable used twice in a snippet must match the same code: `` `$fn && $fn()` `` matches `foo && foo()` but not `foo && bar()`

### Operators

| Operator | Meaning | Example |
|---|---|---|
| `<:` | matches | `$method <: "log"` |
| `contains` | search descendants | `$value <: contains JsTemplateExpression()` |
| `or { ... }` | match any | `$m <: or { "log", "warn" }` |
| `not` | negate | `not $name <: r".*Icon"` |
| `as $var` | alias a match | `contains "color: $c" as $rule` |
| `where { ... }` | add conditions | `` `$x` where { $x <: `foo` } `` |

### Regex

Use `r"pattern"` to match captured text against a regex:

```grit
$name <: r".*Icon"
```

### Named AST nodes

Use Biome's PascalCase AST types for precise matching:

```grit
jsx_attribute(name = "className", $value) where {
    $value <: contains JsTemplateExpression(),
    register_diagnostic(span = $value, message = "Use cn() instead")
}
```

Common node types:
- `JsxAttribute`, `JsxElement`, `JsxSelfClosingElement`, `JsxOpeningElement`
- `JsTemplateExpression`, `JsCallExpression`, `JsIfStatement`
- `JsxExpressionChild` (for `{expr}` in JSX)

Both snake_case (`jsx_attribute`) and PascalCase (`JsxAttribute`) work. Discover node names via the [Biome Playground](https://biomejs.dev/playground/) syntax tree view.

## Examples

### Disallow template literals in className

```grit
engine biome(1.0)
language js(jsx)

jsx_attribute(name = "className", $value) where {
    $value <: contains JsTemplateExpression(),
    register_diagnostic(
        span = $value,
        message = "Use cn() instead of template literal in className",
        severity = "error"
    )
}
```

### Disallow Object.assign

```grit
engine biome(1.0)
language js

`$fn($args)` where {
    $fn <: `Object.assign`,
    register_diagnostic(
        span = $fn,
        message = "Prefer object spread instead of Object.assign()"
    )
}
```

### CSS: disallow explicit color declarations

```grit
engine biome(1.0)
language css

`$selector { $props }` where {
    $props <: contains `color: $color` as $rule,
    not $selector <: r"\.color-.*",
    register_diagnostic(
        span = $rule,
        message = "Don't set explicit colors. Use .color-* classes instead."
    )
}
```

## Configuration

Add plugins in `biome.json`:

```json
{
  "plugins": [
    "plugins/my-rule.grit"
  ]
}
```

Paths are resolved relative to the `biome.json` file. For plugins installed via npm:

```json
{
  "plugins": [
    "./node_modules/@scope/my-plugins/plugins/rule.grit"
  ]
}
```

## Testing

Create a test file with both violations and valid code, then run:

```bash
biome lint /tmp/test-file.tsx
```

Plugin diagnostics appear with the `plugin` category in output.

## Limitations

- Only JavaScript and CSS target languages are supported
- No plugin options or configuration per-rule
- No automatic npm package resolution (must use relative paths)
- GritQL support in Biome is still experimental; some GritQL features are missing

## After creating a plugin

After creating a new plugin, update the plugin table in the following files so they stay in sync:
- `README.md` (consumer-facing)
- `AGENTS.md` (agent context)

Add a row to the plugin table in each file with the plugin filename (without extension) and a short description.

## References

- Plugin docs: https://biomejs.dev/linter/plugins
- GritQL reference: https://biomejs.dev/reference/gritql
- GritQL language: https://docs.grit.io/language/overview
- Feature tracking: https://github.com/biomejs/biome/issues/2582
