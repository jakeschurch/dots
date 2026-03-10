#!/usr/bin/env bash

QUOTES_FILE="$XDG_CONFIG_HOME/motd/quotes.yaml"

random_index=$(yq -r '.quotes | length' "$QUOTES_FILE")

# Pick a random quote using the random index
random_quote=$(yq -r ".quotes[$((RANDOM % random_index))] | .quote + \"\n- \" + .author" "$QUOTES_FILE")

# Display the quote
echo "$random_quote"
