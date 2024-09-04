-- ~/.config/nvim/lua/nvim-tree-config.lua
-- netrwを無効化
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 24ビットカラーを有効化
vim.opt.termguicolors = true

-- nvim-treeの設定
require('nvim-tree').setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
    git_ignored = false,
  },
})

