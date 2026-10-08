; extends
((string_fragment) @injection.content
  (#match? @injection.content "--\\s+lua")
  (#set! injection.language "lua"))

((string_fragment) @injection.content
  (#match? @injection.content "\"\\s+vim")
  (#set! injection.language "vim"))

((string_fragment) @injection.content
  (#match? @injection.content "#\\s+yaml")
  (#set! injection.language "yaml"))
