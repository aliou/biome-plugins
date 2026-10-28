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
- `language` sets the target language: `js`, `js(jsx)`, `js(typescript)`, `js(typescript, jsx)`, `css`, or `json`.

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

Diagnostics can be suppressed with `// biome-ignore lint/plugin: reason`, or for a rule loaded from this package, `// biome-ignore lint/plugin/@aliou/biome-plugins/<rule>: reason`.

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

The replacement is built from captured metavariables. `let` bindings and string functions (`replace`, `substring`, `lowercase`) fail to compile. Capture the substring instead:

- Metavariables inside string literals match part of the string: `` `foo("$x.js")` `` binds `$x` to `a` in `foo("a.js")`.
- A regex binds its capturing groups to the variables after it: `$source <: r"^[\"'](.*)\.js[\"']$"($path)`, then `` $source => `"$path"` ``. `plugins/no-js-import-extension.grit` uses this.

Mapping one identifier to an unrelated one still cannot be expressed.

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

In `biome.json`, a plugin entry is a path, a package export, or an object with `includes` globs:

```json
{
  "plugins": [
    "./plugins/my-rule.grit",
    { "path": "@aliou/biome-plugins/pi-no-node-exec", "includes": ["extensions/**/*.ts"] }
  ]
}
```

Paths are relative to the `biome.json` file. `includes` patterns can be negated with `!`. This package exports each rule and preset through `biome-manifest.json`. See the `setting-up-biome-plugins` skill for consumer-side setup.

There is no way to pass options or variables into a `.grit` file -- values must be hardcoded in the pattern ([biomejs/biome#10928](https://github.com/biomejs/biome/issues/10928)).

## Testing

Add fixtures to `tests/fail/` and `tests/pass/`, then wire them into `scripts/test.sh`:

- `test_fail <fixture> <message> <count>` asserts the exact number of diagnostics. Exact counts catch rules that stop after the first match.
- `test_pass <fixture>` fails on any diagnostic, warnings included.
- `test_fix <fixture> <expected>` applies all fixes, unsafe ones included, and compares the result to a file in `tests/fixed/`.

Run `pnpm test` inside `nix develop`. For a quick manual check:

```bash
node_modules/.bin/biome lint --config-path tests/plugins.json tests/fail/my-rule.ts
```

Plugin diagnostics appear with the `plugin` category in output.

## Limitations

- Target languages: JavaScript, CSS, and JSON.
- No `let` bindings or string functions.
- No cross-file analysis: patterns only see the file being linted.
- No plugin options; no severity override, no banned-name lists.
- Still experimental; some GritQL features are missing (tracking: [biomejs/biome#2582](https://github.com/biomejs/biome/issues/2582)).

## Gotchas found in practice

- **Every capturing group needs a variable.** `r"(unknown|any)"` errors with `regex pattern matched 1 variables, but expected 0`. Bind it, `r"(unknown|any)"($kind)`, or use a non-capturing group, `r"(?:unknown|any)"`.
- **Match each import specifier, not the import statement.** Snippets such as `` `import { $a, $b } from "os"` `` only match a fixed number of specifiers. Match `or { JsShorthandNamedImportSpecifier() as $spec, JsNamedImportSpecifier() as $spec }` and constrain it with `` $spec <: within `import { $_ } from "os"` ``. `plugins/no-homedir.grit` uses this. Requires Biome 2.5.13 or later.
- **Regex is a full-text match, not a search.** A pattern like `r"^\s*cause\b"` used in a `not` condition to exempt a case looks like "starts with cause", but the regex must match the ENTIRE node text -- against real parameter text like `cause: unknown` it never matches, so the exemption silently never fires. Anchor to the whole shape instead: `r"^\s*cause\b[\s\S]*$"`. The same trap applies to positive matches: `r":\s*unknown$"` misses `value: unknown = fallback` because the node's full text continues past `unknown`; account for optional trailing syntax (`(?:\s*=[\s\S]*)?`) or the match fails on every case that has one.
- **`contains` searches every descendant, not just direct children.** `$sig <: contains TsUnknownType()` on an index signature also matches `unknown` nested arbitrarily deep in the value type (`{ [k: string]: { nested: unknown } }`), a false positive when the rule should only care about the direct value type. Bind the specific field instead and test its own text or shape: `TsIndexSignatureTypeMember(type_annotation = $ann) where { $ann <: r"^\s*:\s*unknown\s*$" }`.
- **Field names for structurally similar positions differ across node kinds.** Return-type annotations aren't one shape: most function-like nodes use `return_type_annotation: TsReturnTypeAnnotation?` (node text includes the leading `:`), but `TsFunctionType`/`TsConstructorType` use `return_type: AnyTsReturnType` directly (no colon in the text), getters (`JsGetterObjectMember`, `JsGetterClassMember`, `TsGetterSignatureClassMember`) use `return_type: TsTypeAnnotation?`, and `TsGetterSignatureTypeMember` uses `type_annotation: TsTypeAnnotation?` instead. Check the field name and text shape per node kind rather than assuming consistency across similar-looking nodes; `js.ungram` in the Biome repo is the source of truth when the Playground syntax tree doesn't make a field name obvious.

## After creating a plugin

1. Add the rule to `plugins.rules` in `biome-manifest.json`, and to a preset only if every project using that preset should get it.
2. Add a row to the rule table in `README.md`.
3. If it joins a preset or stands alone, update the table in `skills/setting-up-biome-plugins/SKILL.md`.

## References

- Plugin docs: https://biomejs.dev/linter/plugins
- Plugin recipes: https://biomejs.dev/recipes/gritql-plugins
- GritQL reference: https://biomejs.dev/reference/gritql
- GritQL language: https://docs.grit.io/language/overview
- Plugins RFC (GritQL + JS/TS plugins): https://github.com/biomejs/biome/discussions/1762
- Feature tracking: https://github.com/biomejs/biome/issues/2582
