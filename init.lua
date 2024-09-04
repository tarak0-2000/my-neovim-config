-- packpathを設定
vim.cmd [[set packpath+=~/.local/share/nvim/site]]

-- プラグイン管理マネージャを読み込む
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'lambdalisue/suda.vim'
  use 'folke/tokyonight.nvim'
  use 'nvim-tree/nvim-web-devicons' -- OPTIONAL: for file icons
  use 'lewis6991/gitsigns.nvim' -- OPTIONAL: for git status
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }
  use {
    'nvim-tree/nvim-tree.lua',
   requires = {'nvim-tree/nvim-web-devicons'} 
   -- tag = 'nightly' -- optional, updated every week. (see issue #1193)
  }
  use {
    'romgrk/barbar.nvim',
    requires = {'nvim-tree/nvim-web-devicons'} 
  }
  use 'RRethy/vim-illuminate'
  use 'nvim-treesitter/nvim-treesitter'
  use 'petertriho/nvim-scrollbar'
  use 'hrsh7th/nvim-cmp' -- Completion plugin
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-buffer' -- Buffer source for nvim-cmp
  use 'hrsh7th/cmp-path' -- Path source for nvim-cmp
  use 'hrsh7th/cmp-cmdline' -- Cmdline source for nvim-cmp
  use 'neovim/nvim-lspconfig' -- LSP configurations
end)

-- lualineの設定を読み込む
require('101-lualine')
-- cmp-nvim-lspの設定を読み込む
require('cmp-config')
require('lsp-config')
-- nvim-treeの設定を読み込む
require('nvim-tree-config')
-- barbarの設定を読み込む
require('barbar-config')
-- nvim-treesitterの設定を読み込む
require('nvim-treesitter-config')
require("nvim-scrollbar-config")
require('lspconfig').pyright.setup{}

-- True Colorを有効にする
if vim.fn.has("termguicolors") == 1 then
  vim.opt.termguicolors = true
end

-- カラースキームをtokyonight-nightに設定
vim.cmd('colorscheme tokyonight-night')

-- 行番号表示 
vim.opt.number = true

-- タブとインデントの設定
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- 検索設定
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- キーマップ
vim.keymap.set("i", "jj", "<esc>")
vim.keymap.set('n', 'FI', vim.cmd.NvimTreeToggle)
vim.keymap.set('n', 'fi', vim.cmd.NvimTreeFocus)
vim.keymap.set('n', '<C-a>', 'ggVG')
vim.keymap.set('n', '<C-S-c>', '"+yy')
vim.keymap.set('v', '<C-S-c>', '"+yy')
vim.keymap.set('n', 'lp', 'VyP')
vim.keymap.set('n', '<Esc>', vim.cmd.noh)
-- ノーマルモードでの保存
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
-- インサートモードでの保存
vim.api.nvim_set_keymap('i', '<C-s>', '<Esc>:w<CR>a', { noremap = true, silent = true })

--クリップボードをOSと共有
vim.opt.clipboard = 'unnamedplus'

-- IME制御
-- augroupを作成
vim.api.nvim_create_augroup('restore-ime', { clear = true })

-- InsertEnterイベントのautocmdを作成
vim.api.nvim_create_autocmd('InsertEnter', {
  group = 'restore-ime',
  pattern = '*',
  callback = function()
    vim.fn.chansend(vim.v.stderr, '\x1b[<r')
  end,
})

-- InsertLeaveイベントのautocmdを作成
vim.api.nvim_create_autocmd('InsertLeave', {
  group = 'restore-ime',
  pattern = '*',
  callback = function()
    vim.fn.chansend(vim.v.stderr, '\x1b[<s\x1b[<0t')
  end,
})

-- VimLeaveイベントのautocmdを作成
vim.api.nvim_create_autocmd('VimLeave', {
  group = 'restore-ime',
  pattern = '*',
  callback = function()
    vim.fn.chansend(vim.v.stderr, '\x1b[<0t\x1b[<s')
  end,
})

-- セッションを保存して再起動するrestartを定義(possession.nvim未実装)
local restart_cmd = nil

if vim.g.neovide then
  if vim.fn.has "wsl" == 1 then
    restart_cmd = "silent! !nohup neovide.exe --wsl &"
  else
    restart_cmd = "silent! !neovide.exe"
  end
elseif vim.g.fvim_loaded then
  if vim.fn.has "wsl" == 1 then
    restart_cmd = "silent! !nohup fvim.exe &"
  else
    restart_cmd = [=[silent! !powershell -Command "Start-Process -FilePath fvim.exe"]=]
  end
end

vim.api.nvim_create_user_command("Restart", function()
  if vim.fn.has "gui_running" then
    if restart_cmd == nil then
      vim.notify("Restart command not found", vim.log.levels.WARN)
    end
  end

  require("possession.session").save("restart", { no_confirm = true })
  vim.cmd [[silent! bufdo bwipeout]]

  vim.g.NVIM_RESTARTING = true

  if restart_cmd then
    vim.cmd(restart_cmd)
  end

  vim.cmd [[qa!]]
end, {})

vim.api.nvim_create_autocmd("VimEnter", {
  nested = true,
  callback = function()
    if vim.g.NVIM_RESTARTING then
      vim.g.NVIM_RESTARTING = false
      require("possession.session").load "restart"
      require("possession.session").delete("restart", { no_confirm = true })
      vim.opt.cmdheight = 1
    end
  end,
})

