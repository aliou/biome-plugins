---
name: writing-gritql-plugins
description: Writing custom Biome lint rules as GritQL plugins. Use when creating, editing, or debugging .grit files for Biome's plugin system. Covers GritQL pattern syntax, CST node matching, metavariables, the register_diagnostic API, code fixes with rewrites, and testing patterns.
---

# Writing GritQL Plugins

GritQL is a structural pattern matching language that operates on Biome's syntax tree. Each plugin is a `.grit` file that matches code patterns and emits diagnostics.

## File structure

Every `.grit` file requires two headers:

```grit
engine biome(1.0)
language js(jsx)
```

- `engine biome(1.0)` tells GritQL to use Biome's syntax tree (not Tree-sitter's).
- `language` sets the target language: `js`, `js(jsx)`, `js(typescript)`, `js(typescript,jsx)`, `css`, or `json`.

After headers, write one or more patterns with conditions and `register_diagnostic()` calls.

## Plugin API

One function is available:

```grit
register_diagnostic(
    span = $node,           -- required: AST node to underline
    message = "...",        -- required: diagnostic message
    severity = "error",     -- optional: error (default), warn, info, hint
    fix_kind = "unsafe"     -- optional: safe or unsafe (default), for rewrites
)
```

Diagnostics can be suppressed with `// biome-ignore lint/plugin: reason` comments.

## Code fixes (rewrites)

A match can be rewritten with `=>`, turning the diagnostic into a fixable one:

```grit
`console.log($msg)` as $call where {
    register_diagnostic(
        span = $call,
        message = "Use console.info instead of console.log.",
        severity = "warn",
        fix_kind = "safe"
    ),
    $call => `console.info($msg)`
}
```

- Without `--write`, rewrites are shown as suggestions but not applied.
- `fix_kind = "safe"`: applied by `biome check --write`.
- `fix_kind = "unsafe"` (default, also when omitted): applied only with `--write --unsafe`.

### Fix constraints

The replacement must be built structurally from captured metavariables. The engine offers no string computation:

- `let` bindings fail to compile.
- String functions (`replace`, `substring`, `lowercase`) fail to compile.
- Metavariables inside string literals compile but never match: `` `"./$path.js"` `` is a dead end.

So fixes that require computing a new string -- stripping a `.js` suffix from an import path, mapping one identifier to another -- cannot be expressed today (tracked in [biomejs/biome#2582](https://github.com/biomejs/biome/issues/2582)).

## Pattern syntax

### Code snippets

Backtick-wrapped code matches structurally (ignores formatting, quote style, whitespace):

```grit
`console.log($msg)`
```

### Metavariables

- `$name` captures an AST node.
- `$_` is a wildcard (match but don't capture).
- `$...` is the spread metavariable: matches zero or more arguments or list elements without binding them. `` `$collection.forEach($...)` `` matches any number of arguments.
- `$first, $...` requires at least one argument: `$first` must bind to something.
- The same variable used twice in a snippet must match the same code: `` `$fn && $fn()` `` matches `foo && foo()` but not `foo && bar()`.

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

`r"pattern"` matches against the full text of a node, including quotes and punctuation:

```grit
JsParameters() as $params where {
    $params <: r".*,.*,.*,.*",   -- 4+ parameters means 3+ commas
    register_diagnostic(span = $params, message = "Too many parameters")
}
```

Useful when the shape you need has no dedicated syntax node (hex colors, keyword-prefixed statements, naming conventions).

### Named CST nodes

Match Biome's concrete syntax tree nodes directly. Names are PascalCase (`JsConditionalExpression`, `TsAnyType`, `JsonMemberName`); both snake_case (`jsx_attribute`) and PascalCase work in snippets.

Nodes support **field matching**, nested like type assertions:

```grit
JsCatchClause(body = JsBlockStatement(statements = [])) as $catch where {
    register_diagnostic(
        span = $catch,
        message = "Empty catch blocks are not allowed. Handle the error or add a comment explaining why it is ignored."
    )
}
```

Combine unrelated syntax shapes under one `or`, unifying arms with the same `as $match` variable so a shared `where` clause can reference them:

```grit
or {
    `eval($code)` as $match,
    `new Function($...)` as $match
} where {
    register_diagnostic(span = $match, message = "Dynamic code evaluation is not allowed.")
}
```

Discover node names in the [Biome Playground](https://biomejs.dev/playground/): paste the code, switch to the **Syntax** tab, and read node names and fields from the tree. Node names are tied to Biome's parser and may change between versions.

For JSON plugins, snippets with metavariables are not supported; match CST nodes like `JsonMemberName()` and filter with regex instead.

## Examples

### Disallow template literals in className (real plugin)

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

### CSS: disallow explicit colors

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

In `biome.json`, a plugin entry is a path string or an object with `includes` globs (Biome >= 2.5):

```json
{
  "plugins": [
    "./plugins/my-rule.grit",
    { "path": "./plugins/pi-no-node-exec.grit", "includes": ["extensions/**/*.ts"] }
  ]
}
```

Paths are relative to the `biome.json` file. `includes` patterns can be negated with `!`. See the `setting-up-biome-plugins` skill for consumer-side setup.

There is no way to pass options or variables into a `.grit` file -- values must be hardcoded in the pattern ([biomejs/biome#10928](https://github.com/biomejs/biome/issues/10928)).

## Testing

Add fixtures to `tests/fail/` (must trigger, with the expected message) and `tests/pass/` (must lint clean), wire them into `scripts/test.sh`, then run:

```bash
pnpm test
```

For a quick manual check, lint a file that should trigger:

```bash
npx biome lint /tmp/test-file.tsx
```

Plugin diagnostics appear with the `plugin` category in output.

## Limitations

- Target languages: JavaScript, CSS, and JSON.
- No `let` bindings or string functions; metavariables inside string literals never match.
- No cross-file analysis: patterns only see the file being linted.
- No plugin options; no severity override, no banned-name lists.
- No automatic npm package resolution (must use relative paths).
- Still experimental; some GritQL features are missing (tracking: [biomejs/biome#2582](https://github.com/biomejs/biome/issues/2582)).

## After creating a plugin

Update the plugin table in the following files so they stay in sync:
- `README.md` (consumer-facing)
- `AGENTS.md` (agent context)
- `skills/setting-up-biome-plugins/SKILL.md` (setup skill)

Add a row with the plugin filename (without extension) and a short description, plus a relevance note in the setup skill.

## References

- Plugin docs: https://biomejs.dev/linter/plugins
- Plugin recipes: https://biomejs.dev/recipes/gritql-plugins
- GritQL reference: https://biomejs.dev/reference/gritql
- GritQL language: https://docs.grit.io/language/overview
- Plugins RFC (GritQL + JS/TS plugins): https://github.com/biomejs/biome/discussions/1762
- Feature tracking: https://github.com/biomejs/biome/issues/2582
