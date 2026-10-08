# walp

A free, open-source live wallpaper app for macOS — a Wallper-style browser with a
Liquid Glass interface, playing video wallpapers on your desktop.

> Status: early. Desktop playback + Liquid Glass UI work today. Lock-screen /
> screen-saver support (the "Backdrop way") is planned — see Roadmap.

## Features

- **Browse & apply** video wallpapers from an in-app gallery (no System Settings trip).
- **Liquid Glass UI** (macOS 26) with a graceful material fallback on older systems.
- **Desktop engine** that plays a looping, muted video behind your desktop icons.
- **Multi-display** aware; rebuilds wallpaper windows when screens change.
- **Menu bar** control with a Stop button.
- Bundled, redistribution-safe wallpapers (Public Domain). See `CREDITS.md`.

## Requirements

- macOS 26 for the full Liquid Glass look (builds and runs on earlier macOS with a
  material fallback).
- Xcode 17+ / Swift 6.

## Architecture

```
walp/
├── WalpApp.swift                     App entry: main window + MenuBarExtra
├── Models/
│   ├── Wallpaper.swift               Wallpaper model (gradient + bundled/remote video)
│   └── WallpaperLibrary.swift        Catalog + apply()/clear(); sample data
├── Views/
│   ├── BrowseView.swift              Gallery: featured banner, glass chips, grid
│   ├── WallpaperCard.swift           Grid card with glass label strip
│   ├── FeaturedBanner.swift          Hero banner
│   ├── MenuBarView.swift             Menu bar panel
│   └── Glass.swift                   Liquid Glass helper (glassy / glassyTinted)
├── Engine/
│   ├── DesktopWallpaperController.swift   ACTIVE: borderless desktop-level video windows
│   └── WallpaperInstaller.swift           PARKED: writes to a wallpaper extension's container
└── Extension/
    └── LibraryWatcher.swift               PARKED: extension-side library watcher
```

**How the desktop engine works:** `DesktopWallpaperController` creates one borderless
`NSWindow` per screen at `.desktopWindow` level (below the icons), click-through, playing
the video via `AVQueuePlayer` + `AVPlayerLooper` in an `AVPlayerLayer`. `apply(wallpaper)`
resolves the bundled video and starts playback; `clear()` tears the windows down.

**Parked (future lock screen):** `WallpaperInstaller` + `LibraryWatcher` implement the
Phosphene-style contract (app writes videos into a sandboxed wallpaper extension's
container, signalled over a Darwin notification). Not wired into the current build.

## Build

1. Open `walp.xcodeproj` in Xcode.
2. Ensure all files under `Models/`, `Views/`, and `Engine/DesktopWallpaperController.swift`
   are in the **walp** target (Build Phases → Compile Sources).
3. Add the bundled video files to Build Phases → Copy Bundle Resources.
4. Build & run. Click a wallpaper to play it on the desktop.

## Wallpaper licensing

Only bundle clips cleared for redistribution (Public Domain / CC0). The usual free-stock
sites (Pexels, Pixabay, Mixkit) forbid redistributing their clips inside an app, so they
are **not** used here. Current bundled sources and licenses are listed in `CREDITS.md`.

## Roadmap

- [ ] Still-frame-on-desktop by default, with an "Animate on Desktop" toggle (battery-friendly).
- [ ] Persist the chosen wallpaper and reapply on launch / login.
- [ ] Lock screen + screen saver via macOS aerial / idle-assets injection (macOS 15+),
      the technique Backdrop uses. Requires research of the `idleassetsd` format.
- [ ] Download-on-demand for larger remote wallpapers (`remoteURL`), e.g. NASA 4K clips.
- [ ] Playlists / shuffle, per-display selection, smart pause under fullscreen apps.

## License

MIT. See `LICENSE`. Bundled wallpaper videos are licensed separately — see `CREDITS.md`.
