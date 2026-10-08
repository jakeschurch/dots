vim.filetype.add({
  extension = {
    hml = "yaml",
  },
  pattern = {
    [".*/%.github[%w/]+workflows[%w/]+.*%.ya?ml"] = "yaml.github",
    ["Chart%.ya?ml"] = "yaml",
    ["docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
    ["docker%-compose.*%.yaml"] = "yaml.docker-compose",
    [".*%.gitlab%-ci.*%.ya?ml"] = "yaml.gitlab",
    [".*/%.gitlab%-ci/.*%.ya?ml"] = "yaml.gitlab",
  },
})
