#!/usr/bin/env bash

set -e

if [ $# -eq 0 ]; then
  "$0" "$PWD"
else
  for arg in "$@"; do
    echo "Inspecting $arg" >&2
    pushd "$arg" &>/dev/null
    find . -maxdepth 1 -print0 | \
    if which parallel &>/dev/null; then
      parallel -0 -k 'du -sh'
    else
      ln=0
      while IFS= read -r -d $'\0' path; do
        let ln=$ln+1
        if [ $ln -eq 1 ]; then continue; fi
        du -sh "$path"
      done
    fi | \
    sed -n 's_\s\+\./\?\(.*\)$_\t\1_p' | \
    sort -h -k1 | \
    tee .disk-tree
    popd &>/dev/null
  done
fi
