-- [nfnl] Compiled from fnl/ddc_source_neorg/internal/treesitter.fnl by https://github.com/Olical/nfnl, do not edit.
local util = require("ddc_source_neorg.internal.util")
local function parse_query(language, query)
  if vim.treesitter.query.parse then
    return vim.treesitter.query.parse(language, query)
  else
    return vim.treesitter.parse_query(language, query)
  end
end
local function get_bufnr_parser(language, bufnr)
  return vim.treesitter.get_parser(bufnr, language)
end
local function get_file_parser(language, file)
  return vim.treesitter.get_string_parser(file, language)
end
local function get_parser(language, source)
  local _2_ = type(source)
  if (_2_ == "string") then
    return get_file_parser(language, source)
  elseif (_2_ == "number") then
    return get_bufnr_parser(language, util.normalize_bufnr(source))
  else
    local _ = _2_
    return nil
  end
end
local function execute_query(language, query, callback, bufnr)
  local query0 = parse_query(language, query)
  local parser = get_bufnr_parser(language, bufnr)
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
local function get_bufnr_node_text(node, bufnr)
  local _5_ = {node, bufnr}
  if ((nil ~= _5_[1]) and (nil ~= _5_[2])) then
    local node0 = _5_[1]
    local source = _5_[2]
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
    local _ = _5_
    return ""
  end
end
local function get_file_node_text(node, path)
  local _, _0, start_bytes = node:start()
  local _1, _2, end_bytes = node:end_()
  return string.sub(path, (start_bytes + 1), end_bytes)
end
local function get_node_text(node, source)
  local _9_ = type(source)
  if (_9_ == "string") then
    return get_file_node_text(node, source)
  elseif (_9_ == "number") then
    return get_bufnr_node_text(node, util.normalize_bufnr(source))
  else
    local _ = _9_
    return ""
  end
end
local norg
local function _11_(source)
  return get_parser("norg", source)
end
local function _12_(query)
  return parse_query("norg", query)
end
local function _13_(query, callback, bufnr_3f)
  return execute_query("norg", query, callback, util.normalize_bufnr(bufnr_3f))
end
norg = {get_parser = _11_, parse_query = _12_, execute_query = _13_}
return {norg = norg, get_node_text = get_node_text}
