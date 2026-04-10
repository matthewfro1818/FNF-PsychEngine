# Funkin Base Asset Port Report

- Source: `funkin-windows-64bit/assets`
- Destination: `FNF-PsychEngine/assets/base_game`
- V-Slice song metadata/chart pairs were converted into `assets/base_game/shared/data/<song-id>/`.
- Source stage JSONs were converted into `assets/base_game/shared/stages/*.json`.
- Raw audio/media/week folders were linked into `assets/base_game` with NTFS junctions to avoid duplicating the full build.
- Raw source stage scripts were mirrored to `assets/base_game/shared/stages/_source_scripts/` for manual follow-up.
- Raw source data trees that do not map directly to Psych were mirrored under `assets/base_game/_source_port/`.
