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
local anchor = require("ddc_source_neorg.anchor")
local link = require("ddc_source_neorg.link")
local function current_buffer(id)
  return cb(id, vim.api.nvim_buf_get_name(0))
end
local function current_workspace(id)
  local neorg = require("neorg")
  local dirman = neorg.modules.get_module("core.dirman")
  local workspace = dirman.get_current_workspace()
  local name = workspace[1]
  local path = workspace[2]:tostring()
  return cb(id, {name = name, path = path})
end
local function language_list(id)
  local syntax = get_runtime_files("syntax/*.vim")
  local after_syntax = get_runtime_files("after/syntax/*.vim")
  local parser = get_runtime_files("parser/*.so")
  local languages = {}
  for _, fs in ipairs({syntax, after_syntax, parser}) do
    for _0, f in ipairs(fs) do
      table.insert(languages, f)
    end
  end
  return cb(id, languages)
end
local function anchor_list(id)
  return cb(id, anchor.get_anchors())
end
local local_link
do
  local heading_list
  local function _2_(id, level)
    return cb(id, link["local"].get_headings(level))
  end
  heading_list = _2_
  local footnote_list
  local function _3_(id)
    return cb(id, link["local"].get_footnotes())
  end
  footnote_list = _3_
  local generic_list
  local function _4_(id)
    return cb(id, link["local"].get_generics())
  end
  generic_list = _4_
  local_link = {heading_list = heading_list, footnote_list = footnote_list, generic_list = generic_list}
end
local foreign_link
do
  local heading_list
  local function _5_(id, path, level)
    return cb(id, link.foreign.get_headings(path, level))
  end
  heading_list = _5_
  local footnote_list
  local function _6_(id, path)
    return cb(id, link.foreign.get_footnotes(path))
  end
  footnote_list = _6_
  local generic_list
  local function _7_(id, path)
    return cb(id, link.foreign.get_generics(path))
  end
  generic_list = _7_
  foreign_link = {heading_list = heading_list, footnote_list = footnote_list, generic_list = generic_list}
end
return {current_buffer = current_buffer, current_workspace = current_workspace, language_list = language_list, anchor_list = anchor_list, ["local"] = local_link, foreign = foreign_link}
