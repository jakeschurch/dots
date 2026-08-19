-- gitgood.lua config. Auto-loaded by get_plugins (lua/plugin/**/*.lua).
require("gitgood").setup({
  cache = { disk = true }, -- persist sha-keyed file blobs to ~/.cache/nvim/gitgood
})
