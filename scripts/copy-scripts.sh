#!/bin/bash

src="../scripts"
dest="."
self="copy-scripts.sh"

for f in "$src"/*; do
    [ -f "$f" ] || continue                      # skip directories
    [ "$(basename "$f")" = "$self" ] && continue # skip this script
    cp -p "$f" "$dest/"
done

echo "Copied scripts from $src into $(pwd) (excluded $self)"
