#!/usr/bin/env sh
# embedpuml.sh — build SVG/PDF from PlantUML with verbose logging
set -eu

log() { printf '%s %s\n' "[embedpuml]" "$*" >&2; }

lsdir() {
  d=$1
  if [ -d "$d" ]; then
    log "Listing of $d:"
    ls -la "$d"
  else
    log "Directory does not exist: $d"
  fi
}

BASENAME=${1:?Usage: embedpuml.sh <basename-without-ext>}
DIR=$(dirname -- "$BASENAME")
BASE=$(basename -- "$BASENAME")

PUML="$DIR/$BASE.puml"
SVG="$DIR/$BASE.svg"
PDF="$DIR/$BASE.pdf"

log "Started at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
log "PWD: $(pwd)"
log "PATH: $PATH"
log "BASENAME: $BASENAME"
log "DIR: $DIR"
log "BASE: $BASE"
log "PUML: $PUML"
log "SVG: $SVG"
log "PDF: $PDF"

# Tool availability and versions
if command -v plantuml >/dev/null 2>&1; then
  log "plantuml found: $(command -v plantuml)"
  log "plantuml version:"
  plantuml -version | head -n 1 >&2 || true
else
  log "plantuml not found in PATH"
fi

if command -v inkscape >/dev/null 2>&1; then
  log "inkscape found: $(command -v inkscape)"
  log "inkscape version:"
  inkscape --version >&2 || true
else
  log "inkscape not found in PATH"
fi

log "Initial directory listings"
lsdir "$(pwd)"
lsdir "$DIR"

# Stage: export SVG from PUML
if [ -e "$PUML" ]; then
  log "PUML exists: $PUML"
  if [ ! -e "$SVG" ] || [ "$PUML" -nt "$SVG" ]; then
    log "Generating SVG via plantuml..."
    # plantuml -tsvg creates SVG in the same directory as PUML by default
    plantuml -tsvg "$PUML"
    rc=$?
    log "plantuml exit code: $rc"
    lsdir "$DIR"
  else
    log "SVG is up-to-date: $SVG"
  fi
else
  log "PUML NOT found: $PUML"
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
