#!/bin/bash
OUT=""
LAST_GRP=""
for SRC in $*; do
	if [[ $SRC =~ ^(.*)-([0-9]+)-([0-9]+)-(.*)\.jpg$ ]]; then
		GROUP="${BASH_REMATCH[1]}"
		SEMESTER="${BASH_REMATCH[2]}"
		CLASS="${BASH_REMATCH[3]}"
		TOPIC="${BASH_REMATCH[4]}"
		if [[ $SRC =~ ^(.*)-small.jpg$ ]]; then
			echo "Ignoring $SRC"
			continue
		fi

		if [[ "$LAST_GRP" != "$GROUP" ]]; then
			OUT+="\n"
			LAST_GRP="$GROUP"
		fi

		# Direct image
		#OUT+="<a href=\"$SRC\">\n"
		#OUT+="    <img align=\"right\" src=\"${GROUP}-${SEMESTER}-${CLASS}-${TOPIC}-small.jpg\" style=\"height:85px\">\n"
		#OUT+="</a>\n"
		# Gallery
		OUT+="<img align=\"right\" src=\"${GROUP}-${SEMESTER}-${CLASS}-${TOPIC}-small.jpg\" data-full=\"$SRC\" style=\"height:85px\" class=\"obrazek\">\n"
	else
		echo "Incorrect file name $SRC"
	fi

	EXT="$(echo "$SRC" | rev | cut -d'.' -f1 | rev)"
	SMALL="${SRC%.$EXT}-small.$EXT"
	if [ -e "$SMALL" ]; then
		echo "Existing $SMALL"
	else
		echo "Creating $SMALL"
		jpegoptim -m 80 "$SRC" 2>&1
		convert "$SRC" -resize 150x150 -quality 60 "$SMALL" 2>&1
	fi
done

echo
echo -e "$OUT"
