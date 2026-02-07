# biome-plugins

Custom Biome lint rules written as GritQL plugins.

## Plugins

| Plugin | Description |
|---|---|
| `no-inline-imports` | Disallows `await import()` and `require()` inside functions. All imports should be static `import` statements at the top of the file. |
| `no-interpolated-classname` | Disallows template literals in `className` attributes. Enforces using a `cn()` utility instead. |
| `phosphor-icon-suffix` | Enforces that Phosphor icon imports end with the `Icon` suffix (e.g. `HouseIcon`, not `House`). |

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

Pick only the ones you need. Each plugin is a standalone `.grit` file.

### 3. Run

Plugin diagnostics show up when running `biome lint` or `biome check` as usual:

```bash
biome check .
```

## Limitations

Biome's plugin system is still experimental. There is no automatic npm package resolution for plugins -- you must use explicit relative paths to `node_modules` as shown above.

See [biomejs/biome#6265](https://github.com/biomejs/biome/discussions/6265) for the ongoing discussion on plugin distribution.
