-- [nfnl] Compiled from fnl/ddc_source_neorg/init.fnl by https://github.com/Olical/nfnl, do not edit.
local function cb(id, value)
  return vim.api.nvim_call_function("ddc#callback", {id, value})
end
local function get_runtime_files(path)
  local tbl_21_auto = {}
  local i_22_auto = 0
  for _, name in pairs(vim.api.nvim_get_runtime_file(path, true)) do
    local val_23_auto = vim.fn.fnamemodify(name, ":t:r")
    if (nil ~= val_23_auto) then
      i_22_auto = (i_22_auto + 1)
      tbl_21_auto[i_22_auto] = val_23_auto
    else
    end
  end
  return tbl_21_auto
end
local function get_current_buffer(id)
  return cb(id, vim.api.nvim_buf_get_name(0))
end
local function get_language_list(id)
  local syntax = get_runtime_files("syntax/*.vim")
  local after_syntax = get_runtime_files("after/syntax/*.vim")
  local parser = get_runtime_files("parser/*.so")
  local files = {}
  for _, fs in ipairs({syntax, after_syntax, parser}) do
    for _0, f in ipairs(fs) do
      table.insert(files, f)
    end
  end
  return cb(id, {languages = files})
end
local function get_current_workspace(id)
  local neorg = require("neorg")
  local dirman = neorg.modules.get_module("core.dirman")
  local workspace = dirman.get_current_workspace()
  local name = workspace[1]
  local path = workspace[2]:tostring()
  return cb(id, {name = name, path = path})
end
local function get_anchor_list(id)
  local anchor = require("ddc_source_neorg.anchor")
  local anchors = anchor["get-anchors"]()
  return cb(id, anchors)
end
return {["get-current-buffer"] = get_current_buffer, ["get-language-list"] = get_language_list, ["get-current-workspace"] = get_current_workspace, ["get-anchor-list"] = get_anchor_list}
