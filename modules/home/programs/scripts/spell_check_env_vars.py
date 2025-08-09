#!/usr/bin/env python3

import os
import re
import sys
import argparse
from spellchecker import SpellChecker

def split_env_var(var_name):
    """Splits environment variable names into words based on underscores."""
    return re.split(r'[_]+', var_name)

def check_env_vars(env_vars, allowlist):
    """Checks a list of environment variable names for spelling errors, allowing allowlisted words."""
    spell = SpellChecker()
    spell.word_frequency.load_words(allowlist)
    flagged_vars = {}

    for var in env_vars:
        words = split_env_var(var)
        misspelled = list(spell.unknown(words))

        if misspelled:
            suggestions = {word: spell.correction(word) for word in misspelled}
            flagged_vars[var] = suggestions

    return flagged_vars

def read_vars_from_files(files):
    """Reads environment variable names from files."""
    env_vars = set()
    for file in files:
        try:
            with open(file, 'r') as f:
                for line in f:
                    match = re.match(r'^([A-Z0-9_]+)=', line)
                    if match:
                        env_vars.add(match.group(1))
        except Exception as e:
            print(f"⚠️ Could not read {file}: {e}", file=sys.stderr)
    return env_vars

def read_allowlist(allowlist_file):
    """Reads allowlisted words from a file."""
    if not allowlist_file:
        return set()
    try:
        with open(allowlist_file, 'r') as f:
            return {line.strip() for line in f if line.strip()}
    except Exception as e:
        print(f"⚠️ Could not read allowlist file {allowlist_file}: {e}", file=sys.stderr)
        return set()

def main():
    parser = argparse.ArgumentParser(description="Check environment variables for spelling errors.")
    parser.add_argument("--verbose", action="store_true", help="Show detailed output.")
    parser.add_argument("--files", nargs="*", help="List of files to check for environment variable names.")
    parser.add_argument("--allowlist", help="File containing words that should be ignored.")
    args = parser.parse_args()

    env_vars = set(os.environ.keys())

    if args.files:
        env_vars.update(read_vars_from_files(args.files))

    allowlist = read_allowlist(args.allowlist)

    flagged = check_env_vars(env_vars, allowlist)

    if not flagged:
        print("✅ No spelling errors found in environment variable names.")
        sys.exit(0)

    print("🚨 Potential spelling errors detected in environment variable names:")
    for var, mistakes in flagged.items():
        suggestions = ', '.join(f"{word} -> {suggestion}" for word, suggestion in mistakes.items())
        print(f"  {var}: {suggestions}")

    if args.verbose:
        print("\n🔍 Consider checking these variables manually.")

    sys.exit(1)

if __name__ == "__main__":
    main()
