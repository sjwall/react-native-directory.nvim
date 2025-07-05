# React Native Directory Neovim plugin

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)][pr]

A Neovim plugin that allows browsing through the React Native Directory and performing actions related to the chosen package from a Telescope popup.

## ✨ Features

- 🔭 Search through the packages in the React Native Directory.
- 🔍 Filter by [tokens...](./lua/react-native-directory/tokens.lua) with `:` prefix
- 🚀 `<C-i> to install the selected package in the current workspace using your preferred package manager.

## 📦 Installation

```lua
-- lazy.nvim
{
  'sjwall/react-native-directory.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    vim.keymap.set('n', '<leader>sD', '<CMD>Telescope rnd<CR>', { desc = '[S]earch React Native [D]irectory' })
  end,
}
```

[pr]: http://makeapullrequest.com
