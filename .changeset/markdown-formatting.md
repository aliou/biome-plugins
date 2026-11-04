---
"@aliou/biome-plugins": minor
---

`configs/base` now formats Markdown: paragraphs unwrap to a single line, YAML frontmatter is parsed and formatted, and fenced code blocks are formatted with their language's formatter. Repositories extending the config should expect `.md` files to be reformatted on the next install.
