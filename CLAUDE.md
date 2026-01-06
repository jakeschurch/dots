# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal NixOS/home-manager dotfiles repository using **nixos-unified** and **flake-parts** for managing system and home configurations across multiple machines (NixOS, Darwin, Linux).

## Commands

```bash
# Activate home-manager configuration
nix run

# Build without activating
nix build

# Format all code (nixfmt, shellcheck, etc.)
nix fmt

# Enter development shell
nix develop

# Check flake validity
nix flake check
```

## Architecture

### Flake Structure
- `flake.nix` - Main entry point with 20+ inputs (nixpkgs-unstable, home-manager, nixos-unified, hyprland, etc.)
- `config.nix` - User identity (name, email, username)
- `lib/` - Helper functions (`mkHome.nix`, `mkScript.nix`, `toTOML.nix`)

### Module Organization
```
modules/
├── home/
│   ├── all/           # Cross-platform home-manager modules (auto-imported)
│   │   ├── programs/  # Per-program configs (neovim/, git/, wezterm/, etc.)
│   │   ├── development.nix
│   │   └── default.nix  # Auto-discovers sibling modules via builtins.readDir
│   ├── darwin/        # macOS-specific
│   └── linux-only.nix
├── darwin/            # Darwin system modules
├── nixos/             # NixOS system modules
└── flake/             # Flake-level modules (treefmt, pre-commit, activation)
```

### System Configurations
```
configurations/
├── nixos/apollo/      # Main NixOS system (Hyprland, NVIDIA)
├── darwin/            # macOS machines
└── home/jake.nix      # Home-manager entry
```

### Key Patterns
- **Auto-import**: `modules/home/all/default.nix` auto-imports all sibling `.nix` files
- **Overlays**: `overlays/default.nix` auto-discovers packages in `packages/`
- **Program modules**: Each program gets its own directory under `programs/` with `default.nix` + config files

## Key Directories

| Path | Purpose |
|------|---------|
| `modules/home/all/programs/neovim/` | Neovim config with Lua files in `config/lua/` |
| `modules/home/all/programs/wezterm/` | Wezterm terminal config |
| `modules/home/all/development.nix` | Development packages (Python, Terraform, K8s, etc.) |
| `configurations/nixos/apollo/` | NixOS system config (Hyprland, hardware, disko) |
| `bin/` | Utility shell scripts |
| `packages/` | Custom Nix packages |

## Code Quality

Pre-commit hooks are enabled via `modules/flake/pre-commit-hooks.nix`:
- `nixfmt-rfc-style` - Nix formatting
- `statix`, `deadnix` - Nix linting
- `shellcheck` - Shell script linting
- `treefmt` - Multi-language formatting

## Notes

- Default editor: Neovim (nightly)
- Shell: Zsh with VI keybindings
- Window manager: Hyprland (NixOS), i3 (Linux), Hammerspoon (macOS)
- Secrets: SOPS encryption (`.sops.yaml`)
