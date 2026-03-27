# LuaLaTeX Article Template

A small, batteries-included LuaLaTeX template for homework writeups and short articles.

## Features

- **OpenType fonts, including math**
  - Bundled **Libertinus** OpenType fonts for text.
  - **Libertinus Math** via `unicode-math` so LuaLaTeX can use modern OpenType math glyphs/features.
- **Diagram embedding with automatic rebuilds (Lua helpers)**
  - **Graphviz DOT** → SVG → PDF (`\embeddot{path/basename}`)
  - **PlantUML** → SVG → PDF (`\embedpuml{path/basename}`)
  - **KiCad schematics** (`.kicad_sch`) → SVG → PDF (`\embedkicad{path/basename}`)
  - Outputs are cached under `out/` and only regenerated when the source is newer.

## Repository layout

- `main.tex` — example document demonstrating the integrations
- `config.tex` — font setup and common configuration
- `modules/` — TeX macros (DOT / PlantUML / KiCad embedding)
- `scripts/` — Lua build helpers used by the TeX macros
- `fonts/` — bundled OpenType fonts (Libertinus) + JetBrains Mono
- `out/` — build output directory (created by `latexmk`)

## Dependencies

### Required (core build)

- **LuaLaTeX** (TeX distribution with LuaHBTeX)
- **latexmk**

### Required for diagram embedding

- **Inkscape** (SVG → PDF conversion)

### Optional (enables specific generators)

- **Graphviz** (`dot`) — for `\embeddot`
- **PlantUML** (`plantuml`) **and Java** — for `\embedpuml`
- **KiCad** (`kicad-cli`) — for `\embedkicad`

## Building

This template uses **shell-escape** to call external tools (configured in `.latexmkrc`).

Typical build:

```sh
latexmk main.tex
```

Outputs are written to `out/`.

## Using the embedding macros

All macros take an optional **percent-of-linewidth** argument:

```tex
% DOT
\embeddot{graphs/example}        % 100% of original size
\embeddot[0.8]{graphs/example}   %  80% of original size

% PlantUML
\embedpuml{graphs/embed_workflow}

% KiCad schematic (expects <basename>.kicad_sch)
\embedkicad{circuits/power_stage}
```

Place the source file next to the basename you pass:

- `graphs/example.dot`
- `graphs/embed_workflow.puml`
- `circuits/power_stage.kicad_sch`

## Notes / troubleshooting

- If a generator isn’t installed (e.g. `dot`, `plantuml`, `kicad-cli`, `inkscape`), the corresponding embed command will fail during compilation.
- PlantUML commonly requires Java on your `PATH`.
- If you don’t want external calls, remove `--shell-escape` from `.latexmkrc` and avoid the embedding macros.

## License

See [LICENSE](./LICENSE).
