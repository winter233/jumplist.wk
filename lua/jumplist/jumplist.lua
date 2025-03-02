---@diagnostic disable: missing-fields, inject-field
---@type wk.Plugin
local M = {}

M.name = "jumplist"

M.mappings = {
  icon = { icon = " ", color = "orange" },
  plugin = "jumplist",
  { "<leader>o", desc = "jumplist" },
}

local labels = {
  ["^"] = "Last position of cursor in insert mode",
  ["."] = "Last change in current buffer",
  ['"'] = "Last exited current buffer",
  ["0"] = "In last file edited",
  ["'"] = "Back to line in current buffer where jumped from",
  ["`"] = "Back to position in current buffer where jumped from",
  ["["] = "To beginning of previously changed or yanked text",
  ["]"] = "To end of previously changed or yanked text",
  ["<lt>"] = "To beginning of last visual selection",
  [">"] = "To end of last visual selection",
}

M.cols = {
  { key = "lnum", hl = "Number", align = "right" },
}

function M.expand()
  local tabnr = vim.api.nvim_get_current_tabpage()
  local winnr = vim.api.nvim_get_current_win()
  local items = {} ---@type wk.Plugin.item[]

  local jumps =  vim.fn.getjumplist(winnr, tabnr)[1]

  local keys = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  local idx = 1
  local bs = vim.api.nvim_list_bufs()

  -- only show jump in loaded buffers
  local buffers = {}
  for _, buf in ipairs(bs) do
    if vim.api.nvim_buf_is_loaded(buf) then
      table.insert(buffers, buf)
    end
  end

  for i = #jumps, 1, -1 do
    local jump = jumps[i]
    if vim.tbl_contains(buffers, jump.bufnr) then
      jump.lnum = jump.lnum - 1
      local file = vim.api.nvim_buf_get_name(jump.bufnr)
      file = file and vim.fn.fnamemodify(file, ":p:~:.")
      local symbol = require('jumplist.statusline').statusline(jump)
      local line
      if symbol and symbol ~= "" then
        line = symbol
      else
        line = vim.api.nvim_buf_get_lines(jump.bufnr, jump.lnum, jump.lnum + 1, false)[1]
      end
      table.insert(items, {
        key = keys:sub(idx, idx),
        value = line,
        desc = file .. ":" .. jump.lnum,
        action = function()
          vim.cmd("buffer " .. jump.bufnr)
          -- set the cursor
          vim.api.nvim_win_set_cursor(winnr, { jump.lnum, jump.col })
          vim.cmd("norm! zzzv")
        end,
      })
      idx = idx + 1
    end
  end

  return items
end

return M
