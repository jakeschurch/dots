local notify = require("notify")

notify.setup({
  timeout = 3000,
  render = "wrapped-compact",
  stages = "fade",
  max_width = 30,
})
