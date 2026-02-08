---
name: biome-plugins-changesets
description: Changesets and version bump guidelines for @aliou/biome-plugins. Use when creating changesets or determining version bump type for releases.
---

# Changesets and Version Bumps

When making changes that will be published to npm.

## Creating changesets

Manually create changeset files in `.changeset/` with this format:

```md
---
"@aliou/biome-plugins": <patch|minor|major>
---

Description of the change
```

## Version bump guidelines

- **patch** (0.0.x): Bug fixes, documentation updates, test improvements, internal refactoring
- **minor** (0.x.0): New features, new plugins, backward-compatible additions
- **major** (x.0.0): Breaking changes, removed plugins, changed plugin behavior that affects existing users

## Examples

- Adding a new plugin → **minor**
- Fixing a bug in existing plugin → **patch**
- Updating documentation → **patch**
- Removing a plugin → **major**
- Changing plugin diagnostic behavior → **major**
- Adding test coverage → **patch**

## Workflow

1. Make changes
2. Create changeset file in `.changeset/`
3. Commit changes and changeset together
4. Push to main
5. GitHub Actions creates/updates release PR
6. Merge release PR to publish to npm
