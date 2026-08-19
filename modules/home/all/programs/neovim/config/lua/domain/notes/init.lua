return {
  -- vimwiki sets g:vimwiki_* before its own plugin scripts are sourced.
  first = { "vimwiki" },
  lazy = {
    ["img-clip"] = true,
    presenting = true,
    callouts = true,
    ["render-markdown"] = true,
  },
}
