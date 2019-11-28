#!/bin/bash
for SRC in $*; do
    EXT="$(echo "$SRC" | rev | cut -d'.' -f1 | rev)"
    SMALL="${SRC:0:-$(expr ${#EXT} + 1)}-small.$EXT"
    if [ -e "$SMALL" ]; then
        echo "Existing $SMALL"
    else
        echo "Creating $SMALL"
        convert "$SRC" -resize 150x150 -quality 60 "$SMALL"
    fi
done
