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

- `package.json` — Extension manifest. Declares theme contributions, metadata, version, and icon.
- `themes/liatrio-dark-color-theme.json` — Dark theme definition (workbench colors, token colors, semantic token colors)
- `themes/liatrio-light-color-theme.json` — Light theme definition (same structure, light palette)
- `icon.png` — 128x128 Liatrio flame logo for marketplace listing
- `screenshots/` — Auto-generated theme preview images (dark.png, light.png) and sample code
- `.github/workflows/ci.yml` — Packages extension on PRs
- `.github/workflows/release.yml` — On push to main, creates a GitHub release and publishes to marketplaces if the version in package.json is new
- `.github/workflows/screenshots.yml` — Captures theme screenshots in CI via xvfb; runs on PRs that change themes

## Theme Architecture

Each theme JSON has three sections:

1. **`colors`** — Workbench/UI colors (editor, sidebar, terminal, status bar, etc.)
2. **`tokenColors`** — TextMate scope-based syntax highlighting rules
3. **`semanticTokenColors`** — LSP semantic token overrides

Both themes use the same color roles with dark/light appropriate values. The brand accent color is Liatrio green (`#24ae1d` primary, `#89df00` bright/secondary).

## Release Process

Bump the version in `package.json` and merge to main. The release workflow checks if a git tag exists for that version — if not, it creates a GitHub release with the .vsix and publishes to VS Marketplace (`VSCE_PAT` secret) and Open VSX (`OVSX_PAT` secret).
