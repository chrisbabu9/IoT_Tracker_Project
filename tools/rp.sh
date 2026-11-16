#!/usr/bin/env bash
# Usage: tools/rp.sh <path-substring> [grep-pattern]
# Prints one file from repomix-output.xml using repomix.index (no full reads).
IDX="$(dirname "$0")/repomix.index"; XML="${REPOMIX:-repomix-output.xml}"
read -r P S E _ < <(grep -m1 -F "$1" "$IDX") || { echo "not found"; exit 1; }
if [ -n "$2" ]; then sed -n "$((S+1)),$((E-1))p" "$XML" | grep -n -E "$2"; else sed -n "$((S+1)),$((E-1))p" "$XML"; fi
