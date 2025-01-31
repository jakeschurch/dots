{vimPlugins}: {
  programs.neovim.plugins = with vimPlugins; [
    {
      plugin = vimPlugins.avante-nvim;
      config = ''
        -- lua
        require('avante-nvim').setup();
      '';
    }
  ];
}
