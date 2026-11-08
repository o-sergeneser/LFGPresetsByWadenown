# LFG Presets By Wadenown

Save and reuse application notes, dungeon listing titles/descriptions and raid listing titles/descriptions beside Blizzard's Group Finder.

Open settings with **`/lfp`**, **`/lfgpresets`**, or the **LFG Presets** tab in Dungeons & Raids. A launcher is also available in Blizzard's AddOns settings.

- Account-wide presets and preferences, shared across characters.
- Five initial slots per category, with **+ Slot** to add more.
- Classic and Modern themes; English and Turkish interfaces.
- Independent automatic opening, position and lock settings for each panel.
- Attach panels to native windows, or drag them independently.
- Attach/detach the editor from its list, with live screen-edge switching.
- Optional retention of the native application note between applications.
- Adjustable scale and background opacity.

Open a preset and edit its text. **Ctrl+C** copies the current selection through the native EditBox, saves all draft fields and closes the editor. Paste manually into Blizzard's fields. **Save** saves without copying; **X/Escape** discards changes. **Delete** requires confirmation. Enter does not insert hard line breaks; pasted line breaks become spaces. Character limits are 31 for titles, 255 for descriptions and 63 for application notes.

Blizzard restrictions prevent arbitrary preset autofill into native fields. Note persistence keeps an existing native note rather than writing a preset, and does not store that native note across reloads. Another addon with its own persistence enabled can also retain it when our setting is off.

Settings and presets use account-wide `LFGPresetsByWadenownDB` SavedVariables and are written to disk on normal logout/reload. This folder is loaded directly by WoW: no local build step or third-party addon dependency is required.

## Bundled media

PT Sans Narrow Bold is bundled under SIL Open Font License 1.1. Copyright (c) 2010 ParaType Ltd. The unmodified font and its license are in `Media/Fonts`. SharedMedia and global Blizzard font changes are not required. The native Group Finder launcher follows its neighboring tabs' font.

`Media/Icon.tga` is the simplified in-game icon with a prominent Wade wordmark, checked at 24 and 32 pixels. The original detailed purple artwork for CurseForge is preserved in `docs/branding/CurseForge-Icon.png`. Branding originals and preview PNGs are excluded from the install package.

## Development

Run from this directory with Node.js 22:

```text
npm ci --prefix tests --cache tests/.npm-cache
node tests/run.cjs
node tests/check-font.cjs
node tests/check-project.cjs
```

These are development dependencies only. WoW loads only the modules in the TOC. The tests run Lua under Fengari with a mock UI and cover editing, persistence, localization, attachment, dragging, scrolling, startup safeguards and package metadata. The application-show fixture follows Blizzard 12.1.5.70783 at commit `297d7aaaa736f346b3e036f38ee088eaf7f8c07f` ([source](https://github.com/Gethe/wow-ui-source/blob/297d7aaaa736f346b3e036f38ee088eaf7f8c07f/Interface/AddOns/Blizzard_GroupFinder/Mainline/LFGList.lua)).

Text previews are cached by content, language, width and font size. Truncation uses UTF-8-safe binary search; unchanged labels/fonts skip redundant writes. A 200-slot mock check records zero new width/height measurements across 20 unchanged refreshes, and 10 measurements for one changed long UTF-8 row. This is a work-count regression check, not an in-game FPS/CPU benchmark.

No hidden-UI polling runs continuously. Frame updates are limited to active dragging and an attached list's visible editor, where geometry is checked for native window movement. Card frames are reused; memory still scales with the maximum number of slots opened in a session. Native clipboard order, mouse feel, taint behavior and actual CPU/memory usage require in-game verification.

## Publishing

See [the publishing checklist](docs/PUBLISHING.md). GitHub validation and tag-triggered BigWigs packaging workflows are prepared. No project IDs, credentials, remote uploads or local release ZIPs are included. Font license notices must remain in distributed packages.
