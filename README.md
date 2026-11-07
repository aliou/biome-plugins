# biome-plugins

Custom Biome lint rules written as GritQL plugins, plus shared Biome configs that enable them. Requires Biome 2.6 or later.

## Install

```bash
pnpm add -D @biomejs/biome @aliou/biome-plugins
```

## How to use this package

The package ships configs and presets, and they are not interchangeable:

- A **config** is a complete setup: formatting and linting preferences, organize imports, and the plugin rules that fit the project type. Extend one in `biome.json` and keep only project-specific settings:

```json
{
  "extends": ["@aliou/biome-plugins/configs/base"],
  "files": { "includes": ["**/*.ts", "**/*.json"] }
}
```

- A **preset** is a list of plugin rules, nothing more. It carries no formatting or linting settings. Use one only when you want the rules but not the settings — in a `biome.json` that does not extend a config:

```json
{
  "plugins": ["@aliou/biome-plugins/presets/recommended"]
}
```

- A **plugin** is a single rule. Use one when you want just that rule, without its whole preset:

```json
{
  "plugins": ["@aliou/biome-plugins/no-homedir"]
}
```

## Use a config

| Config | Contents |
| --- | --- |
| `configs/base` | Git ignore file, 2-space indent, Biome's recommended rules, organize imports, and the `recommended` preset. Skips `.pi/` and `.agents/`, and `pnpm-lock.yaml`/`pnpm-workspace.yaml`. Markdown: joins wrapped paragraphs into one line, formats YAML frontmatter and fenced code blocks. |
| `configs/strict` | `base` plus the `strict` preset. |
| `configs/pi-coding-agent-extension` | `base` plus the `pi-coding-agent-extension` preset. For [pi](https://pi.dev) extensions. |

Configs can be combined: `"extends": ["@aliou/biome-plugins/configs/strict", "@aliou/biome-plugins/configs/pi-coding-agent-extension"]`.

## Use plugins directly

Every rule is also shipped as an individual plugin. Enable presets or single rules in `plugins`, singly or mixed:

```json
{
  "plugins": [
    "@aliou/biome-plugins/presets/recommended",
    "@aliou/biome-plugins/no-homedir"
  ]
}
```

A single rule entry is the rule name, without the `.grit` extension: `@aliou/biome-plugins/no-homedir`. Each rule's description lives next to its `.grit` file in the [`plugins/`](./plugins) directory. Do not list a rule that an enabled preset already includes: Biome reports it twice.

| Preset | Use when |
| --- | --- |
| `presets/recommended` | Any TypeScript project with `moduleResolution: "bundler"`. |
| `presets/strict` | Projects that reject type escape hatches. |
| `presets/schema` | Projects that parse all external input with a schema library. |
| `presets/pi-coding-agent-extension` | [pi](https://pi.dev) extensions and packages. |
| `presets/react` | React projects with a `cn()` helper. |

Run `biome inspect plugins` to list which rules each preset enables. Presets do not overlap, so stacking them never reports a rule twice.

To scope a rule or preset to some files, use the object form:

```json
{
  "plugins": [
    {
      "path": "@aliou/biome-plugins/presets/schema",
      "includes": ["src/api/**"]
    }
  ]
}
```

The fixes for the import extension rules need `moduleResolution: "bundler"` in `tsconfig.json`. Apply them with `biome lint --write --unsafe`.

## Development

```bash
nix develop
pnpm install
pnpm test
```
