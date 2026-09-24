#!/usr/bin/env bash

CAST_FILENAME="${1:-my.cast}"

asciinema rec "$CAST_FILENAME"

agg --rows 40 --theme monokai "$CAST_FILENAME" "${CAST_FILENAME/.cast/.gif}"
