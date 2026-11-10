local gitlinker = require("gitlinker")
local hosts = require("gitlinker.hosts")

-- Forgejo serves gitea-style URLs. LAN ssh remotes (origin) point at the
-- forgejo-ssh LB IP, so rewrite them to the public web host.
local function forgejo_url(url_data)
  url_data.host = "git.jakeschurch.com"
  url_data.port = nil
  return hosts.get_gitea_type_url(url_data)
end

gitlinker.setup({
  opts = {
    -- adds current line nr in the url for normal mode
    add_current_line_on_normal_mode = true,
    -- callback for what to do with the url
    action_callback = require("gitlinker.actions").copy_to_clipboard,
    -- print the url after performing the action
    print_url = true,
  },
  callbacks = {
    ["github.com"] = require("gitlinker.hosts").get_github_type_url,
    ["gitlab.com"] = require("gitlinker.hosts").get_gitlab_type_url,
    ["try.gitea.io"] = require("gitlinker.hosts").get_gitea_type_url,
    ["git.jakeschurch.com"] = forgejo_url,
    ["192%.168%.100%.143"] = forgejo_url,
  },
  -- Built-in maps pass the real mode, so visual selections link the range
  mappings = "<leader>gy",
})
