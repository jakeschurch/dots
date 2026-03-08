local notify = require("notify")

notify.setup({
  timeout = 3000,
  render = "wrapped-compact",
  stages = "fade",
  max_width = 80, -- Increased from 30 to avoid truncating messages
  max_height = 20, -- Add max_height to handle longer lists
})
