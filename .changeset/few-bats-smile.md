---
"@aliou/biome-plugins": minor
---

Add the `no-buried-await` plugin to disallow burying `await` inside parentheses. This catches patterns like `return (await foo()) || ""` and `Boolean(await foo())` and encourages awaiting the value first before using it in a separate expression.
