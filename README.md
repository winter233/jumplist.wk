# Jumplist.wk

Jumplist.wk is a [which-key](https://github.com/folke/which-key.nvim) plugin to show jumplist.

- Only show jump in loaded buffers
- Prefer to show symbol name using treesitter

## Installation

- using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "winter233/jumplist.wk",
  lazy = false,
  config = true,
  dependencies = {
    "folke/which-key.nvim",
    -- optional
    "nvim-treesitter/nvim-treesitter"
  }
},
```
