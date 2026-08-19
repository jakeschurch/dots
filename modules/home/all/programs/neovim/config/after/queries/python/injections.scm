; extends

; Highlight SQL inside strings opened with a `--sql` marker comment, matching
; the `-- lua` / `# bash` markers used in the nix and yaml queries.
(((string_content) @injection.content
  (#lua-match? @injection.content "^%s*%-%-%s*sql"))
  (#set! injection.language "sql"))
