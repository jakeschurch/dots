#!/usr/bin/env bash

QUOTES_FILE="$XDG_CONFIG_DIR/motd/quotes.json"

random_index=$(jq -r 'length' "$QUOTES_FILE")

# Pick a random quote using the random index
random_quote=$(jq -r ".[$((RANDOM % random_index))] | .quote + \"\n- \" + .author" "$QUOTES_FILE")

# Display the quote
echo "$random_quote"
