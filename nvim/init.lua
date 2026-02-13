-- Neovim configuration (Lua)
-- This is the primary entry point. It sources init.vim for the current
-- vimscript config, then applies any Lua-specific settings below.
-- As you migrate to Lua, move things from init.vim into this file.

-- Source the vimscript config
local config_dir = vim.fn.stdpath("config")
vim.cmd("source " .. config_dir .. "/init.vim")

-- --- Lua Options ---

-- --- Lua Key Mappings ---

-- --- Lua Plugins (via lazy.nvim, packer, etc.) ---

-- --- Lua Autocommands ---

-- --- Theme / Appearance ---
