-- Extends <C-a>/<C-x> beyond numbers: toggles true/false, &&/||, ==/!=, and
-- shifts letters. sign_aware keeps `-5` incrementing to `-4` rather than
-- flipping the sign, which is what the native behaviour does.
require("add-subtract-ex").setup({
  sign_aware = true,
})
