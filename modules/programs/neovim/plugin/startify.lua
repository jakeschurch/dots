local keymap = require("utils").keymap
keymap("n", "<leader>e", ":Startify<CR>", { noremap = true, silent = true })

vim.cmd([[
            autocmd User Startified setlocal cursorline

            let g:startify_files_number = 5

            let g:startify_lists = [
            \ { "type": "files", "header": ["MRU"] },
            \ { "type": "bookmarks", "header": ["Bookmarks"] },
            \ ]

            let g:startify_bookmarks = [
            \ {'F': "~/.dots/config/nixpkgs/flake.nix"},
            \ {'N': "~/.dots/config/nixpkgs/modules/programs/neovim/default.nix"},
            \ {'n': "~/.dots/config/nixpkgs/modules/programs/neovim/init.vim" },
            \ {'K': "~/.dots/config/nixpkgs/modules/programs/kitty.nix"},
            \ {'d': "~/.dots/config/nixpkgs/modules/development.nix"},
            \ {'g': "~/.dots/config/nixpkgs/modules/programs/git/default.nix"},
            \ {'i': "~/.dots/config/nixpkgs/modules/programs/i3/default.nix"},
            \ ]
          ]])
