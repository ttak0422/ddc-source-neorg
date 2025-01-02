-- [nfnl] Compiled from fnl/ddc_source_neorg/link.fnl by https://github.com/Olical/nfnl, do not edit.
local util = require("ddc_source_neorg.internal.util")
local treesitter = require("ddc_source_neorg.internal.treesitter")
local generic = "[(_ [(strong_carryover_set (strong_carryover name: (tag_name) @tag_name (tag_parameters) @title (#eq? @tag_name \"name\"))) (weak_carryover_set (weak_carryover name: (tag_name) @tag_name (tag_parameters) @title (#eq? @tag_name \"name\")))]? title: (paragraph_segment) @title) (inline_link_target (paragraph) @title)]"
local definition, footnote = nil, nil
do
  local template = "(REPLACE_list (strong_carryover_set (strong_carryover name: (tag_name) @tag_name (tag_parameters) @title (#eq? @tag_name \"name\")))? . [(single_REPLACE (weak_carryover_set (weak_carryover name: (tag_name) @tag_name (tag_parameters) @title (#eq? @tag_name \"name\")))? (single_REPLACE_prefix) title: (paragraph_segment) @title) (multi_REPLACE (weak_carryover_set (weak_carryover name: (tag_name) @tag_name (tag_parameters) @title (#eq? @tag_name \"name\")))? (multi_REPLACE_prefix) title: (paragraph_segment) @title)])"
  definition, footnote = string.gsub(template, "REPLACE", "definition"), string.gsub(template, "REPLACE", "footnote")
end
local other_template = "(%s [(strong_carryover_set (strong_carryover name: (tag_name) @tag_name (tag_parameters) @title (#eq? @tag_name \"name\"))) (weak_carryover_set (weak_carryover name: (tag_name) @tag_name (tag_parameters) @title (#eq? @tag_name \"name\")))]? (%s_prefix) title: (paragraph_segment) @title)"
local function get_query(link_type)
  if (link_type == "generic") then
    return generic
  elseif (link_type == "definition") then
    return definition
  elseif (link_type == "footnote") then
    return footnote
  elseif (nil ~= link_type) then
    local other = link_type
    return string.format(other_template, other, other)
  else
    return nil
  end
end
local function get_links(link_type, bufnr_3f)
  local bufnr = util["normalize-bufnr"](bufnr_3f)
  local query_string = get_query(link_type)
  local parser = treesitter["get-neorg-parser"](bufnr)
  if (nil ~= parser) then
    local parser0 = parser
    local links = {}
    local query = treesitter["parse-neorg-query"](query_string)
    local tree = parser0:parse()[1]
    for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
      if (query.captures[id] == "title") then
        local tmp_3_auto = treesitter["get-node-text"](node, bufnr)
        if (nil ~= tmp_3_auto) then
          local tmp_3_auto0 = string.gsub(tmp_3_auto, "\\", "")
          if (nil ~= tmp_3_auto0) then
            local tmp_3_auto1 = string.gsub(tmp_3_auto0, "%s+", "")
            if (nil ~= tmp_3_auto1) then
              local tmp_3_auto2 = string.gsub(tmp_3_auto1, "^%s", "")
              if (nil ~= tmp_3_auto2) then
                local function _2_(title)
                  return table.insert(links, title)
                end
                _2_(tmp_3_auto2)
              else
              end
            else
            end
          else
          end
        else
        end
      else
      end
    end
    return links
  else
    local _ = parser
    return {}
  end
end
local function get_local_footnotes()
  return get_links("footnote", 0)
end
local function get_local_headings(level)
  return get_links(string.format("heading%d", level), 0)
end
local function get_local_generics()
  return get_links("generic", 0)
end
return {["get-local-footnotes"] = get_local_footnotes, ["get-local-headings"] = get_local_headings, ["get-local-generics"] = get_local_generics}
