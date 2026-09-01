# @aliou/biome-plugins

## 0.14.0

### Minor Changes

- 34e8111: Add `no-left-border-accent` plugin: flags `border-left` shorthand used as an
  ad-hoc accent stripe on non-`blockquote` boxes (any width), and
  `border-left-width` overrides that thicken one side of a full `border`.
  Exempts the `blockquote` element (any selector form), triangle/arrow shapes,
  and zero-width resets. Targets CSS (`.css` and `<style>` blocks in HTML).

## 0.13.0

### Minor Changes

- 0e03f8d: Add eight plugins ported from [anti-slop](https://github.com/dmmulroy/anti-slop):

  - `no-chained-type-assertions`
  - `no-conditional-empty-object-spread`
  - `no-reflect-apply`
  - `no-reflect-get`
  - `no-runtime-typeof`
  - `no-unknown-parameters`
  - `no-unknown-returns`
  - `no-unsafe-dictionary-type`

- fa85649: Rewrite and rename the bundled skills for Biome 2.5: `writing-gritql-plugins` (was `biome-gritql-plugins`) covers JSON target language, `fix_kind`/`=>` rewrites, suppressions, and includes-scoped plugin entries, plus recipes techniques (`$...` spread, `as $match` unification, CST field matching). `setting-up-biome-plugins` (was `biome-plugins-setup`) adds an audit-first adoption workflow and a full plugin relevance table.

### Patch Changes

- 0f33238: Add the 8 anti-slop-derived plugins to the `setting-up-biome-plugins` skill's relevance table, and document GritQL gotchas found while writing them (non-capturing regex groups, full-text regex matching, `contains` over-matching into nested fields, inconsistent return-type field names) in the `writing-gritql-plugins` skill.

## 0.12.0

### Minor Changes

- ca778e9: Add a plugin that requires `Text` references to have a runtime import binding.

## 0.11.0

### Minor Changes

- b43613d: Add no-is-record plugin to disallow creating `isRecord` function helpers.

## 0.10.0

### Minor Changes

- 52e1735: Add no-homedir plugin: disallows importing `homedir`/`userInfo` from `os`/`node:os` and reading `process.env.HOME`

## 0.9.0

### Minor Changes

- ea5dab6: Catch await expressions buried directly inside call arguments.

### Patch Changes

- a53d66e: Fix pi-no-node-exec to flag multi-name child_process spawning imports while allowing non-spawning imports.

## 0.8.1

### Patch Changes

- ed80bdb: Fix Biome peer dependency to >=2.4.0 (2.5.0 is not released yet)

## 0.8.0

### Minor Changes

- eb09413: Add no-empty-catch plugin: disallows empty catch blocks

### Patch Changes

- 526fb68: Bump Biome peer dependency to >=2.5.0
- ef2d41d: Add biome-plugins-setup skill for configuring plugins in consumer projects

## 0.7.0

### Minor Changes

- c72c019: Add the `no-buried-await` plugin to disallow burying `await` inside parentheses. This catches patterns like `return (await foo()) || ""` and `Boolean(await foo())` and encourages awaiting the value first before using it in a separate expression.

## 0.6.0

### Minor Changes

- 4f2e6c0: Add `pi-no-node-exec` plugin: disallows importing from `child_process` in pi extensions. Use `pi.exec()` instead.

## 0.5.0

### Minor Changes

- 9231b94: Add a new `no-ts-import-extension` plugin that disallows `.ts` extensions in import and re-export paths.

## 0.4.1

### Patch Changes

- 43a9036: Allow dynamic imports and inline type imports inside vi.mock factory callbacks.

## 0.4.0

### Minor Changes

- 0a00dc1: Add a new `no-inner-types` plugin that disallows `type` and `interface` declarations inside function bodies.

## 0.3.2

### Patch Changes

- 5fc2a49: no-inline-imports: detect TsImportType nodes (e.g. `import("module").Type` in type positions)

## 0.3.1

### Patch Changes

- db2f866: Sync plugin tables in README and add post-creation reminder to skill

## 0.3.0

### Minor Changes

- fcd49ce: Correct version bump: new plugins are minor releases, not patches. This bump acknowledges that the no-emojis plugin added in 0.2.1 was a feature addition.

## 0.2.1

### Patch Changes

- 02ffdff: Add no-emojis plugin to disallow emoji characters in string literals, template literals, and JSX text

## 0.2.0

### Minor Changes

- 04b0993: Add no-js-import-extension plugin that disallows .js extensions in import and re-export paths

### Patch Changes

- b900cf9: Bundle biome-gritql-plugins skill for agents working with this package

## 0.1.0

### Minor Changes

- 827fe25: Initial release with three GritQL plugins:
  - no-inline-imports: disallow dynamic imports inside functions
  - no-interpolated-classname: enforce cn() over template literals in className
  - phosphor-icon-suffix: enforce Icon suffix on Phosphor icon imports
