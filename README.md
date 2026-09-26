# cliphist-picker

A fast, minimal **TUI clipboard manager for Wayland**, built around [`cliphist`](https://github.com/sentriz/cliphist) and `fzf`.

Designed for users who want a real clipboard history with **search, text preview, image preview, and keyboard-driven interaction**, without dragging a full GUI application into their desktop.

Works especially well with **Hyprland + Kitty**.

---

## Features

* Full clipboard history powered by `cliphist`
* Fast fuzzy search with `fzf`
* Large preview pane for clipboard contents
* Image previews inside Kitty using the Kitty Graphics Protocol
* Text previews for normal clipboard entries
* Completely keyboard-driven
* Wayland-native
* Designed for NixOS and Home Manager
* Distributed as a Nix flake directly from GitHub
* No daemon, database, or configuration framework beyond `cliphist`

The goal is simple:

```text
┌──────────────────────────────┬──────────────────────────────────────┐
│ clipboard > screenshot       │                                      │
├──────────────────────────────┤                                      │
│ 42  screenshot               │                                      │
│ 41  docker command           │                                      │
│ 40  image                    │          IMAGE/TEXT PREVIEW          │
│ 39  git diff                 │                                      │
│ 38  kubectl command          │                                      │
│                              │                                      │
└──────────────────────────────┴──────────────────────────────────────┘
```

---

## Installation

`cliphist-picker` is distributed as a Nix flake.

Add it to your main `flake.nix`:

```nix
inputs = {
  # ...

  cliphist-picker = {
    url = "github:mhkarimi1383/cliphist-picker";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

Then add the package to Home Manager:

```nix
home.packages = [
  inputs.cliphist-picker.packages.${pkgs.stdenv.hostPlatform.system}.default
  pkgs.cliphist
];
```

After that, rebuild your system

---

## How It Works

`cliphist-picker` does not replace `cliphist`.

`cliphist` remains responsible for storing and retrieving clipboard history, while `cliphist-picker` provides the interactive TUI on top of it.

```text
                    Wayland Clipboard
                           │
               ┌───────────┴───────────┐
               │                       │
          text clipboard         image clipboard
               │                       │
               ▼                       ▼
        wl-paste --watch        wl-paste --watch
               │                       │
               └───────────┬───────────┘
                           ▼
                        cliphist
                           │
                           ▼
                   cliphist-picker
                           │
                    ┌──────┴──────┐
                    │             │
                   fzf         Preview
                    │             │
                    │        ┌────┴─────┐
                    │        │          │
                    │      Kitty      Text
                    │       icat      preview
                    │
                    ▼
                  wl-copy
```

This separation keeps the project small and composable. `cliphist` handles persistence; `cliphist-picker` handles interaction.

---

# Hyprland + Kitty

A typical setup uses two `wl-paste` watchers, one for text and one for images.

For example, with the Hyprland Lua configuration:

```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

hl.bind(
    mainMod .. " + V",
    hl.dsp.exec_cmd("kitty --class cliphist-picker -e cliphist-picker")
)

hl.window_rule({
    name = "cliphist-picker",
    match = {
        class = "cliphist-picker",
    },
    float = true,
    center = true,
    size = "1400 700",
    stay_focused = true,
})
```

With this setup:

```text
Super + V
    │
    ▼
Kitty
    │
    ▼
cliphist-picker
    │
    ├── Search clipboard history
    ├── Preview text
    ├── Preview images
    └── Copy selected entry
```

Kitty is launched with a dedicated window class so the picker can be styled independently from normal terminal windows.

---

## Clipboard Capture

The two watchers are intentional:

```bash
wl-paste --type text --watch cliphist store
wl-paste --type image --watch cliphist store
```

This prevents browsers from storing HTML representations when an actual image MIME type is available.

For example, copying an image from a browser may expose multiple clipboard formats:

```text
image/png
text/html
text/plain
```

The image watcher stores the actual image instead of accidentally turning it into something like:

```html
<meta http-equiv="content-type" ...>
<img src="...">
```

Humanity has apparently decided that copying an image should sometimes produce HTML. This setup avoids that particular act of sabotage.

---

## Running Manually

Once installed:

```bash
cliphist-picker
```

For Kitty:

```bash
kitty --class cliphist-picker -e cliphist-picker
```

---

## Nix Development

Clone the repository:

```bash
git clone https://github.com/mhkarimi1383/cliphist-picker.git
cd cliphist-picker
```

Build it:

```bash
nix build
```

Run it directly:

```bash
nix run
```

Or inspect the resulting package:

```bash
ls -la result/bin/
```

---

## Requirements

Runtime requirements:

* Wayland
* `cliphist`
* `fzf`
* `wl-clipboard`
* Kitty for high-quality image previews

The package provides its required runtime dependencies through its Nix wrapper where appropriate.

---

## Keyboard Interaction

The picker is designed around keyboard navigation.

Typical workflow:

```text
Super + V
   ↓
Search
   ↓
↑ / ↓
   Navigate history
   ↓
Enter
   ↓
Copy selected item
```

The preview pane updates as the selection changes.

---

## Why Another Clipboard Picker?

There are plenty of clipboard managers.

Most of them are either:

* GUI applications
* tied to a particular desktop environment
* visually heavy
* difficult to integrate into a minimal Wayland setup
* or surprisingly complicated for something whose main job is remembering that one piece of text you copied four minutes ago

`cliphist-picker` takes a smaller approach:

```text
cliphist
   +
fzf
   +
Kitty
   =
a fast clipboard picker
```

It stays in the terminal, stays keyboard-driven, and fits naturally into a NixOS/Hyprland workflow.

---

## License

See [`LICENSE`](./LICENSE).

