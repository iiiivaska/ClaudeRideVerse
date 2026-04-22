# FogRide bundled fonts

This directory hosts the two typefaces FogRide uses in production:

- **DM Sans** — all non-numeric text (headings, body, buttons, navigation)
- **IBM Plex Mono** — every numeric value, metric, caps-label, and tag

## Expected files

Drop the following `.ttf` files here. Names must match `FogRideFont.rawValue` cases
(see `Sources/DesignSystem/Tokens/Font+FogRide.swift`):

```
DMSans-Regular.ttf
DMSans-Medium.ttf
DMSans-SemiBold.ttf
DMSans-Bold.ttf
IBMPlexMono-Regular.ttf
IBMPlexMono-Medium.ttf
IBMPlexMono-SemiBold.ttf
OFL.txt
```

## Where to get them

Both typefaces are licensed under **SIL Open Font License 1.1** (OFL-1.1) — redistribution
allowed inside applications. Keep `OFL.txt` alongside the `.ttf` files.

- DM Sans: https://fonts.google.com/specimen/DM+Sans (by Colophon / Indian Type Foundry)
- IBM Plex Mono: https://fonts.google.com/specimen/IBM+Plex+Mono (by Mike Abbink / IBM)

## Fallback behaviour

Until the `.ttf` files are dropped in, `FogRideFontRegistrar.register()` emits a DEBUG log
and every `Font.fog*` accessor falls through to `.system(design: .monospaced / .default)`.
This keeps `swift test`, Xcode Previews, and the Gallery app runnable without the assets.
