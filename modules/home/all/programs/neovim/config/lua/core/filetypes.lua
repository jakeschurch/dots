vim.filetype.add({
  extension = {
    hml = "yaml",
  },
  pattern = {
    [".*/%.github[%w/]+workflows[%w/]+.*%.ya?ml"] = "yaml.github",
    ["helmfile%.ya?ml"] = "yaml.helm-values",
    [".*/templates/.*%.ya?ml"] = "yaml.helm-values",
    ["Chart%.ya?ml"] = "yaml",
    ["docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
    ["docker%-compose.*%.yaml"] = "yaml.docker-compose",
    [".*%.gitlab%-ci.*%.ya?ml"] = "yaml.gitlab",
    [".*/%.gitlab%-ci/.*%.ya?ml"] = "yaml.gitlab",
  },
})
