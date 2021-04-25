#!/usr/bin/env bash

set -e

if [ $# -eq 0 ]; then
  "$0" "$PWD"
else
  # Need to use GNU sed; try to use it, if available
  if which gsed &>/dev/null; then
    sed="gsed"
  else
    echo "Not sure GNU sed is being used; empty results may ensue" >&2
    sed="sed"
  fi
  for arg in "$@"; do
    echo "Inspecting $arg" >&2
    pushd "$arg" &>/dev/null
    (find . -maxdepth 1 -print0 || true) | \
    if which parallel &>/dev/null; then
      parallel -0 -k 'du -sh'
    else
      ln=0
      while IFS= read -r -d $'\0' path; do
        let ln=$ln+1
        if [ $ln -eq 1 ]; then continue; fi
        du -sh "$path" || true
      done
    fi | \
    "$sed" -n 's_\s\+\./\?\(.*\)$_\t\1_p' | \
    sort -h -k1 | \
    tee .disk-tree
    popd &>/dev/null
  done
fi
