; extends
(
  (string_fragment) @lua
  (#match? @lua "--\\s+lua")
)

(
  (string_fragment) @vim
  (#match? @vim "\"\\s+vim")
)

(
  (string_fragment) @yaml
  (#match? @yaml "#\\s+yaml")
)
