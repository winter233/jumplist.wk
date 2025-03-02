local M = {}

-- Trim spaces and opening brackets from end
local transform_line = function(line)
  return line:gsub("%s*[%[%(%{]*%s*$", "")
end

function M.statusline(opts)
  if not package.loaded['nvim-treesitter'] then
    return ""
  end
  local parsers = require "nvim-treesitter.parsers"
  local ts_utils = require "nvim-treesitter.ts_utils"

  if not parsers.has_parser() then
    return ""
  end
  local options = opts or {}
  local bufnr = options.bufnr or 0
  local indicator_size = options.indicator_size or 100
  local type_patterns = options.type_patterns or { "class", "function", "method" }
  local transform_fn = options.transform_fn or transform_line
  local separator = options.separator or " -> "
  local allow_duplicates = options.allow_duplicates or false

  local root_lang_tree = parsers.get_parser(bufnr)
  local root = ts_utils.get_root_for_position(opts.lnum, opts.col, root_lang_tree)
  if not root then
    return ""
  end
  local current_node = root:named_descendant_for_range(opts.lnum, opts.col, opts.lnum, opts.col)
  -- local current_node = ts_utils.get_node_at_cursor()
  if not current_node then
    return ""
  end

  local lines = {}
  local expr = current_node

  while expr do
    local line = ts_utils._get_line_for_node(expr, type_patterns, transform_fn, bufnr)
    if line ~= "" then
      if allow_duplicates or not vim.tbl_contains(lines, line) then
        table.insert(lines, 1, line)
      end
    end
    expr = expr:parent()
  end

  local text = table.concat(lines, separator)
  local text_len = #text
  if text_len > indicator_size then
    return "..." .. text:sub(text_len - indicator_size, text_len)
  end

  return text
end

return M
