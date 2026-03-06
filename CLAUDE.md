# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A VS Code color theme extension providing two variants: **Liatrio Dark** and **Liatrio Light**. Inspired by liatrio.com branding. No build step, no dependencies, no tests — it's purely declarative JSON.

## Key Commands

```bash
# Package the extension into a .vsix file
npx @vscode/vsce package

# Test locally: install the .vsix in VS Code
code --install-extension *.vsix
```

## Project Structure

- `package.json` — Extension manifest. Declares the two theme contributions and metadata. Version is managed by release-please.
- `themes/liatrio-dark-color-theme.json` — Dark theme definition (workbench colors, token colors, semantic token colors)
- `themes/liatrio-light-color-theme.json` — Light theme definition (same structure, light palette)
- `.github/workflows/ci.yml` — Packages extension on push/PR to main
- `.github/workflows/release-please.yml` — Automated releases via release-please; publishes to VS Marketplace and Open VSX

## Theme Architecture

Each theme JSON has three sections:
1. **`colors`** — Workbench/UI colors (editor, sidebar, terminal, status bar, etc.)
2. **`tokenColors`** — TextMate scope-based syntax highlighting rules
3. **`semanticTokenColors`** — LSP semantic token overrides

Both themes use the same color roles with dark/light appropriate values. The brand accent color is Liatrio green (`#24ae1d` primary, `#89df00` bright/secondary).

## Release Process

Uses [release-please](https://github.com/googleapis/release-please) with conventional commits. Merging the release PR bumps the version in `package.json` and `.release-please-manifest.json`, then publishes to VS Marketplace (`VSCE_PAT` secret) and Open VSX (`OVSX_PAT` secret).
