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
local function get_file_node_text(node, path)
  local _, _0, start_bytes = node:start()
  local _1, _2, end_bytes = node:end_()
  return string.sub(path, (start_bytes + 1), end_bytes)
end
local function get_node_text(node, src)
  local _7_ = type(src)
  if (_7_ == "string") then
    return get_file_node_text(node, src)
  elseif (_7_ == "number") then
    return get_bufnr_node_text(node, src)
  else
    local _ = _7_
    return ""
  end
end
local function _9_(query)
  return parse_query("norg", query)
end
local function _10_(bufnr_3f)
  return get_bufnr_parser("norg", util["normalize-bufnr"](bufnr_3f))
end
local function _11_(file)
  return get_file_parser("norg", file)
end
local function _12_(query, callback, bufnr_3f)
  return execute_query("norg", query, callback, util["normalize-bufnr"](bufnr_3f))
end
local function _13_(node, bufnr_3f)
  return get_node_text(node, util["normalize-bufnr"](bufnr_3f))
end
return {["parse-neorg-query"] = _9_, ["get-neorg-bufnr-parser"] = _10_, ["get-neorg-file-parser"] = _11_, ["execute-neorg-query"] = _12_, ["get-node-text"] = _13_}
