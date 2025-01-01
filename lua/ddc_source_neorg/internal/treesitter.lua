-- [nfnl] Compiled from fnl/ddc_source_neorg/internal/treesitter.fnl by https://github.com/Olical/nfnl, do not edit.
local util = require("ddc_source_neorg.internal.util")
local function parse_query(language, query)
  if vim.treesitter.query.parse then
    return vim.treesitter.query.parse(language, query)
  else
    return vim.treesitter.parse_query(language, query)
  end
end
local function get_parser(language, bufnr)
  return vim.treesitter.get_parser(bufnr, language)
end
local function execute_query(language, query, callback, bufnr)
  local query0 = parse_query(language, query)
  local parser = get_parser(language, bufnr)
  if parser then
    do
      local root = parser:parse()[1]:root()
      for id, node in query0:iter_captures(root, bufnr) do
        if callback(query0, id, node) then break end
        -- nop
      end
    end
    return true
  else
    return false
  end
end
local function get_node_text(node, bufnr)
  local _3_ = {node, bufnr}
  if ((nil ~= _3_[1]) and (nil ~= _3_[2])) then
    local node0 = _3_[1]
    local source = _3_[2]
    local start_row, start_col = node0:start()
    local eof_row = vim.api.nvim_buf_line_count(source)
    local end_row, end_col = nil, nil
    do
      local row, col = node0:end_()
      if (row >= eof_row) then
        end_row, end_col = (eof_row - 1), -1
      else
        end_row, end_col = row, col
      end
    end
    if (start_row >= eof_row) then
      return ""
    else
      local lines = vim.api.nvim_buf_get_text(source, start_row, start_col, end_row, end_col, {})
      return table.concat(lines, "\\n")
    end
  else
    local _ = _3_
    return ""
  end
end
local function _7_(query, callback, bufnr_3f)
  return execute_query("norg", query, callback, util["normalize-bufnr"](bufnr_3f))
end
local function _8_(node, bufnr_3f)
  return get_node_text(node, util["normalize-bufnr"](bufnr_3f))
end
return {["execute-neorg-query"] = _7_, ["get-node-text"] = _8_}
