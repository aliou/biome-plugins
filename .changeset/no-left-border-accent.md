---
"@aliou/biome-plugins": minor
---

Add `no-left-border-accent` plugin: flags `border-left` shorthand used as an
ad-hoc accent stripe on non-`blockquote` boxes (any width), and
`border-left-width` overrides that thicken one side of a full `border`.
Exempts the `blockquote` element (any selector form), triangle/arrow shapes,
and zero-width resets. Targets CSS (`.css` and `<style>` blocks in HTML).
