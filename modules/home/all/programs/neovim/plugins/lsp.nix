{ pkgs, ... }:
with pkgs.vimPlugins;
[
  lspsaga-nvim
  nvim-lspconfig
  otter-nvim
  # Copies lists with `{ unpack(t) }`, which hits LuaJIT's unpack limit ("too
  # many results to unpack") once a buffer or line carries thousands of
  # diagnostics. `vim.list_slice` takes the same arguments and loops instead.
  (tiny-inline-diagnostic-nvim.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      find lua -name '*.lua' -exec sed -Ei 's/\{ unpack\(([^)]*)\) \}/vim.list_slice(\1)/g' {} +
      ! grep -rn 'unpack(' lua
    '';
  }))
  trouble-nvim
]
