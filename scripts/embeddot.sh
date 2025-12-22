#!/usr/bin/env sh
# embeddot.sh — build SVG/PDF from Graphviz DOT with verbose logging
set -eu

log() { printf '%s %s\n' "[embeddot]" "$*" >&2; }

lsdir() {
  d=$1
  if [ -d "$d" ]; then
    log "Listing of $d:"
    ls -la "$d"
  else
    log "Directory does not exist: $d"
  fi
}

BASENAME=${1:?Usage: embeddot.sh <basename-without-ext>}
DIR=$(dirname -- "$BASENAME")
BASE=$(basename -- "$BASENAME")

DOT="$DIR/$BASE.dot"
OUT_DIR="out/$DIR"
SVG="$OUT_DIR/$BASE.svg"
PDF="$OUT_DIR/$BASE.pdf"

log "Started at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
log "PWD: $(pwd)"
log "PATH: $PATH"
log "BASENAME: $BASENAME"
log "DIR: $DIR"
log "BASE: $BASE"
log "DOT: $DOT"
log "SVG: $SVG"
log "PDF: $PDF"

# Tool availability and versions
if command -v dot >/dev/null 2>&1; then
  log "dot found: $(command -v dot)"
  log "dot version:"
  dot -V >&2 || true
else
  log "dot not found in PATH"
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

# Stage: export SVG from DOT
if [ -e "$DOT" ]; then
  log "DOT file exists: $DOT"
  if [ ! -e "$SVG" ] || [ "$DOT" -nt "$SVG" ]; then
    log "Generating SVG via dot..."
    lsdir "$DIR"
    dot -Tsvg "$DOT" -o "$SVG"
    rc=$?
    log "dot exit code: $rc"
    lsdir "$DIR"
  else
    log "SVG is up-to-date: $SVG"
  fi
else
  log "DOT NOT found: $DOT"
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
