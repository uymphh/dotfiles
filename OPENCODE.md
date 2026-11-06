# OpenCode — Ultra-Minimal, TUI-First NixOS

## Mission

Design and implement an extremely lightweight, highly optimized, fully declarative NixOS configuration.

The goal is not to make a conventional desktop environment slightly lighter. The goal is to build a system with the absolute minimum practical resource consumption while remaining functional, maintainable, and comfortable to use.

My priorities, in order:

1. Maximum possible battery life.
2. Minimum practical RAM consumption.
3. Minimum CPU usage and background activity.
4. Minimum number of running processes and services.
5. Minimal graphical stack and dependencies.
6. TUI-first workflow: prefer terminal applications over graphical applications.
7. Fully declarative, reproducible configuration.
8. Good hardware support and reliable operation.

Do not prioritize aesthetics, animations, desktop effects, or visual customization.

## Hardware

My laptop is an MSI Thin 15 B13VE:

- Intel hybrid CPU (Performance and Efficiency cores).
- Intel integrated graphics.
- NVIDIA GeForce RTX 4050 Max-Q.
- UEFI firmware.
- Laptop battery and power-management constraints.

Inspect the actual hardware and current configuration before making assumptions.

## 1. NixOS architecture

Mandatory requirements:

- NixOS.
- Nix flakes.
- Home Manager.
- Nixpkgs unstable exclusively.
- Modular configuration.
- Declarative system and user configuration.

Use this Nixpkgs input:

`nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";`

Home Manager must follow the same Nixpkgs input:

`home-manager.inputs.nixpkgs.follows = "nixpkgs";`

Requirements:

- Use `flake.nix` and `flake.lock`.
- Keep system configuration and user configuration logically separated.
- Use Home Manager for user packages, shell configuration, dotfiles, and user-level services where appropriate.
- Prefer reusable Nix modules.
- Keep all configuration in version-controlled Nix files.
- Do not use `nix-env`.
- Do not install software imperatively.
- Do not manually edit generated configuration files.
- Do not mix stable and unstable Nixpkgs.
- Understand that `flake.lock` pins exact revisions. Update it intentionally rather than fetching arbitrary revisions during every rebuild.

The configuration should be understandable and easy to maintain, not unnecessarily complicated.

## 2. TUI-first philosophy

This is a very important requirement.

I genuinely enjoy terminal applications. I have absolutely no problem using a TUI instead of a GUI, even when a graphical alternative exists.

**Do not assume I need a graphical application just because one is more conventional.**

Whenever selecting software, investigate whether a capable TUI alternative exists first.

Examples:

- File manager: `lf`, `yazi`, `ranger`, or another lightweight TUI.
- Process monitor: `btop`, `htop`, or `top`.
- System monitor: lightweight CLI tools.
- Network management: `nmtui` or another suitable terminal interface.
- Text editor: `vim`, `neovim`, or another terminal editor.
- Music player: a terminal-based player if practical.
- Image viewing: terminal-compatible tools where useful.
- PDF viewing: terminal-based options where practical.
- File searching: `fzf`, `fd`, `ripgrep`.
- System information: lightweight CLI tools.
- Package and system management: native Nix commands.

These are examples, not mandatory packages. Evaluate their actual resource usage and dependencies.

Prefer applications that:

- Do not require a graphical toolkit.
- Do not run unnecessary background daemons.
- Have low memory usage.
- Have low CPU overhead.
- Work well with keyboard-driven workflows.
- Integrate naturally with the shell.

A GUI should only be introduced when it provides a meaningful advantage or is genuinely necessary.

## 3. Window manager and graphical environment

I am willing to use a very minimal graphical environment, or avoid one entirely where practical.

If a graphical session is necessary, investigate the lightest suitable solution.

Evaluate:

- `dwm`
- `2bwm`
- `bspwm`
- `spectrwm`
- `herbstluftwm`
- `i3`
- `Sway`
- Other lightweight alternatives you consider appropriate.

Do not automatically choose i3 or Sway.

Compare candidates based on:

- Idle RAM consumption.
- CPU usage.
- Dependencies.
- Number of required processes.
- X11 versus Wayland requirements.
- Battery implications.
- Hardware compatibility.
- Configuration complexity.

Investigate whether an X11 or Wayland stack is more appropriate for this particular hardware and goal.

Do not install a full desktop environment.

Avoid unnecessary:

- Panels.
- Widgets.
- Desktop compositors.
- Animations.
- Notifications.
- Graphical settings applications.
- Background desktop services.

If a terminal-only workflow can replace a graphical component, prefer the terminal-only option.

## 4. Essential graphical utilities

Only install what is actually needed.

Investigate lightweight alternatives for:

- Application launching.
- Terminal emulation.
- Clipboard management, if necessary.
- Screenshots, if necessary.
- Display configuration.
- Audio control.

For example, compare `dmenu`, `bemenu`, and lightweight alternatives to Rofi.

For terminals, compare options such as `st`, `foot`, and `xterm`.

Do not install a graphical utility merely because it is common in desktop configurations.

## 5. Min Browser

I specifically want Min Browser.

Official repository:

https://github.com/minbrowser/min

Requirements:

- Install it declaratively through Nix.
- First check whether a suitable package exists in Nixpkgs unstable.
- If unavailable, investigate creating a proper Nix derivation.
- Pin the upstream source.
- Use reproducible hashes and proper build dependencies.
- Do not download or install it imperatively.
- Do not silently replace it with another browser.

Important: Min uses Electron. Its minimal interface does not necessarily mean low memory consumption.

Evaluate its real resource footprint and explain the trade-offs. Keep it because it is explicitly requested, but do not pretend it is the most resource-efficient browser.

## 6. Battery optimization

Battery life is the highest priority.

Investigate and implement the best practical configuration for this laptop.

Consider:

- Intel P-state and CPU frequency scaling.
- Intel hybrid CPU scheduling.
- CPU idle states and C-states.
- Runtime power management.
- PCIe ASPM.
- USB autosuspend.
- Wi-Fi power saving.
- Audio power saving.
- Display refresh rate and brightness considerations.
- NVIDIA GPU runtime power management.
- NVIDIA PRIME offloading.
- Kernel configuration and available power-saving features.

Compare tools and approaches such as:

- TLP.
- power-profiles-daemon.
- tuned.
- auto-cpufreq.
- powertop.
- Native kernel and systemd capabilities.

Do not enable conflicting power-management services.

Prefer native kernel and system capabilities when they provide the same functionality without additional background processes.

The Intel integrated GPU should handle normal desktop usage.

The NVIDIA GPU should remain powered down when unused, if hardware and driver support permit it, while remaining available for applications that explicitly need it.

Do not sacrifice hardware reliability or essential functionality for insignificant theoretical savings.

## 7. RAM and CPU optimization

Minimize actual resource consumption.

Investigate:

- Running services.
- Kernel modules.
- Graphical stack overhead.
- Background daemons.
- Logging configuration.
- Memory allocation and caching.
- ZRAM and swap configuration.
- Unnecessary hardware polling.
- Unnecessary timers and wakeups.

Do not confuse Linux filesystem cache with wasted RAM.

Do not disable essential services just to make process counts look smaller.

The objective is lower actual overhead, not an artificially impressive process count.

## 8. Services and system components

Audit every enabled service.

For each service, explain:

- What it does.
- Whether it is necessary.
- Whether it runs continuously.
- Its approximate resource cost.
- Whether a lighter alternative exists.

Keep only what is needed for a functional laptop, such as:

- Essential hardware support.
- Networking.
- Audio, if needed.
- Login/session management.
- Power management.
- Required system services.

Avoid unnecessary graphical services and desktop-oriented daemons.

## 9. Configuration structure

Use a clean, modular structure.

For example:

- `flake.nix`
- `flake.lock`
- `hosts/`
- `modules/`
- `modules/system/`
- `modules/hardware/`
- `modules/power/`
- `modules/desktop/`
- `home/`
- `home/modules/`

This is only a suggested structure. Choose something sensible rather than creating modules for the sake of modularity.

Keep system-level and user-level responsibilities separate.

## 10. Research and benchmarking

Do not make assumptions based solely on software descriptions or popularity.

Compare actual resource usage whenever possible.

Measure or investigate:

- Idle RAM usage after boot.
- Idle CPU usage.
- Number of running processes.
- Battery discharge rate.
- CPU frequency and idle behavior.
- Wakeups per second.
- NVIDIA GPU power state.
- Boot time.
- Graphical session overhead.

Use comparable conditions when benchmarking.

Explain the difference between theoretical optimization and measured improvement.

Do not claim a particular window manager, terminal, or service is the lightest without evidence.

## 11. Implementation rules

Before changing anything:

1. Inspect the existing NixOS configuration.
2. Inspect the hardware.
3. Identify the bootloader and current boot setup.
4. Inspect the kernel and graphics configuration.
5. Audit existing services.
6. Identify existing functionality that must be preserved.

Then propose a plan before making substantial changes.

Important:

- Do not make destructive changes without explaining them.
- Preserve a bootable configuration.
- Validate Nix syntax.
- Evaluate the flake before switching configurations.
- Build and test changes incrementally.
- Explain important decisions.
- Keep a working previous NixOS generation available.
- Do not make changes that could unnecessarily break Windows dual boot or UEFI boot configuration.

## 12. Final desired result

The final system should have:

- NixOS unstable.
- Flakes.
- Home Manager.
- A modular declarative configuration.
- A TUI-first workflow.
- The minimum practical graphical environment.
- A lightweight tiling window manager only if needed.
- A minimal terminal emulator if a graphical session is used.
- Min Browser installed declaratively.
- Essential networking and audio functionality.
- Intel integrated graphics for normal operation.
- NVIDIA GPU available on demand, preferably powered down when unused.
- Aggressive but safe battery optimization.
- Minimal background activity and RAM consumption.

Do not add software just because it is conventional.

Do not assume that every task requires a GUI.

**The guiding principle is: terminal-first, minimal dependencies, minimal background activity, maximum battery life, and everything declarative through Nix.**

## 13. First task

Before implementing anything:

1. Audit my current system and hardware.
2. Identify what is currently consuming RAM and battery.
3. Research and compare lightweight TUI applications.
4. Compare window managers and graphical-stack options.
5. Determine whether a mostly terminal-based environment is practical.
6. Propose the best architecture for my goals.
7. Explain trade-offs, especially between battery life, RAM usage, and functionality.

Present the proposed architecture and reasoning before implementing it.
