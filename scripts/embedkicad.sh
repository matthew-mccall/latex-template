#!/usr/bin/env sh
# embedkicad.sh — build SVG/PDF from KiCad schematic with verbose logging
set -eu

log() { printf '%s %s\n' "[embedkicad]" "$*" >&2; }

lsdir() {
  d=$1
  if [ -d "$d" ]; then
    log "Listing of $d:"
    ls -la "$d"
  else
    log "Directory does not exist: $d"
  fi
}

BASENAME=${1:?Usage: embedkicad.sh <basename-without-ext>}
DIR=$(dirname -- "$BASENAME")
BASE=$(basename -- "$BASENAME")

SCH="$DIR/$BASE.kicad_sch"
OUT_DIR="out/$DIR"
SVG="$OUT_DIR/$BASE.svg"
PDF="$OUT_DIR/$BASE.pdf"

log "Started at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
log "PWD: $(pwd)"
log "PATH: $PATH"
log "BASENAME: $BASENAME"
log "DIR: $DIR"
log "BASE: $BASE"
log "SCH: $SCH"
log "SVG: $SVG"
log "PDF: $PDF"

# Tool availability and versions
if command -v kicad-cli >/dev/null 2>&1; then
  log "kicad-cli found: $(command -v kicad-cli)"
  log "kicad-cli version:"
  kicad-cli --version >&2 || true
else
  log "kicad-cli not found in PATH"
fi

if command -v inkscape >/dev/null 2>&1; then
  log "inkscape found: $(command -v inkscape)"
  log "inkscape version:"
  inkscape --version >&2 || true
else
  log "inkscape not found in PATH"
fi

# Create output directory if it doesn't exist
mkdir -p "$OUT_DIR"

log "Initial directory listings"
lsdir "$(pwd)"
lsdir "$DIR"
lsdir "$OUT_DIR"

# Stage: export SVG from schematic
if [ -e "$SCH" ]; then
  log "Schematic exists: $SCH"
  if [ ! -e "$SVG" ] || [ "$SCH" -nt "$SVG" ]; then
    log "Generating SVG via kicad-cli..."
    lsdir "$DIR"
    kicad-cli sch export svg --exclude-drawing-sheet --black-and-white --output "$OUT_DIR" "$SCH"
    rc=$?
    log "kicad-cli exit code: $rc"
    lsdir "$DIR"
  else
    log "SVG is up-to-date: $SVG"
  fi
else
  log "Schematic NOT found: $SCH"
fi

# Stage: convert SVG to PDF
if [ -e "$SVG" ]; then
  log "SVG exists: $SVG"
  if [ ! -e "$PDF" ] || [ "$SVG" -nt "$PDF" ]; then
    log "Converting SVG to PDF via inkscape..."
    lsdir "$DIR"
    inkscape "$SVG" --export-area-drawing --export-type=pdf --export-filename="$PDF"
    rc=$?
    log "inkscape exit code: $rc"
    lsdir "$DIR"
    if [ -e "$PDF" ]; then
      log "Generated PDF: $PDF"
    else
      log "PDF generation failed: $PDF"
    fi
  else
    log "PDF is up-to-date: $PDF"
  fi
else
  log "SVG NOT found: $SVG"
fi