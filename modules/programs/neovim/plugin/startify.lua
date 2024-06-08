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
            \ {'F': "~/.dots/flake.nix"},
            \ {'N': "~/.dots/modules/programs/neovim/default.nix"},
            \ {'n': "~/.dots/modules/programs/neovim/init.vim" },
            \ {'K': "~/.dots/modules/programs/kitty.nix"},
            \ {'d': "~/.dots/modules/development.nix"},
            \ {'g': "~/.dots/modules/programs/git/default.nix"},
            \ {'i': "~/.dots/modules/programs/i3/default.nix"},
            \ ]
          ]])
