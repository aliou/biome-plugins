# @aliou/biome-plugins

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
