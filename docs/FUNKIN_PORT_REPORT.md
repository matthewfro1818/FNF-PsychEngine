# Funkin Port Report

Imported content was copied from `funkin-windows-64bit\mods` into Psych Engine `example_mods`.

Notes:
- Raw mod files were preserved.
- V-Slice chart pairs were converted into Psych chart JSONs under each mod `data/<song-id>/` folder.
- Placeholder week files were generated so songs show up in Story/Freeplay.
- Placeholder character/stage JSONs were generated only when Psych-native ones were missing.
- Compatibility `.hx` stubs were generated for songs, characters, stages, custom events, and custom note types.
- Original `.hxc` / source-side scripts were copied for manual follow-up, but they are not auto-translated to Psych gameplay scripts.

## FNF: GOOEY MIX

- Source folder: `mods/FNF Gooey Mix`
- Generated songs: 34
- Generated weeks: 34
- Placeholder Psych character files are only fallbacks. Custom character behavior still needs manual porting from the copied scripts.
- Safe Psych HScript placeholders were generated for the load points Psych recognizes so missing scripts are visible in-game instead of failing silently.
- Large asset folders were linked into `example_mods` with NTFS junctions to avoid duplicating the original build on disk.

## QT: Rewired

- Source folder: `mods/qt-rewired-pc_48d1f`
- Generated songs: 5
- Generated weeks: 5
- Placeholder Psych character files are only fallbacks. Custom character behavior still needs manual porting from the copied scripts.
- Safe Psych HScript placeholders were generated for the load points Psych recognizes so missing scripts are visible in-game instead of failing silently.
- Large asset folders were linked into `example_mods` with NTFS junctions to avoid duplicating the original build on disk.

