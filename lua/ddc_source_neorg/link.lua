-- [nfnl] Compiled from fnl/ddc_source_neorg/link.fnl by https://github.com/Olical/nfnl, do not edit.
local util = require("ddc_source_neorg.internal.util")
local treesitter = require("ddc_source_neorg.internal.treesitter")
local generic = "\n[(_\n  [(strong_carryover_set\n     (strong_carryover\n       name: (tag_name) @tag_name\n       (tag_parameters) @title\n       (#eq? @tag_name \"name\")))\n   (weak_carryover_set\n     (weak_carryover\n       name: (tag_name) @tag_name\n       (tag_parameters) @title\n       (#eq? @tag_name \"name\")))]?\n  title: (paragraph_segment) @title)\n  (inline_link_target (paragraph) @title)]"
local definition, footnote = nil, nil
do
  local template = "\n(REPLACE_list\n  (strong_carryover_set\n    (strong_carryover\n      name: (tag_name) @tag_name\n      (tag_parameters) @title\n      (#eq? @tag_name \"name\")))?\n  .\n  [(single_REPLACE\n     (weak_carryover_set\n       (weak_carryover\n         name: (tag_name) @tag_name\n         (tag_parameters) @title\n         (#eq? @tag_name \"name\")))?\n     (single_REPLACE_prefix)\n     title: (paragraph_segment) @title)\n   (multi_REPLACE\n     (weak_carryover_set\n       (weak_carryover\n         name: (tag_name) @tag_name\n         (tag_parameters) @title\n         (#eq? @tag_name \"name\")))?\n     (multi_REPLACE_prefix)\n     title: (paragraph_segment) @title)])"
  definition, footnote = string.gsub(template, "REPLACE", "definition"), string.gsub(template, "REPLACE", "footnote")
end
local other_template = "\n(%s\n  [(strong_carryover_set\n     (strong_carryover\n       name: (tag_name) @tag_name\n       (tag_parameters) @title\n       (#eq? @tag_name \"name\")))\n   (weak_carryover_set\n     (weak_carryover\n       name: (tag_name) @tag_name\n       (tag_parameters) @title\n       (#eq? @tag_name \"name\")))]?\n  (%s_prefix)\n  title: (paragraph_segment) @title)"
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
local function get_links(parser_3f, query_string, src)
  if (nil ~= parser_3f) then
    local parser = parser_3f
    local links = {}
    local query = treesitter["parse-neorg-query"](query_string)
    local tree = parser:parse()[1]
    for id, node in query:iter_captures(tree:root(), src, 0, -1) do
      if (query.captures[id] == "title") then
        local tmp_3_auto = treesitter["get-node-text"](node, src)
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
    local _ = parser_3f
    return {}
  end
end
local function get_bufnr_links(link_type, bufnr_3f)
  local bufnr = util["normalize-bufnr"](bufnr_3f)
  local parser = treesitter["get-neorg-bufnr-parser"](bufnr)
  return get_links(parser, get_query(link_type), bufnr)
end
local function get_file_links(link_type, file)
  if (vim.fn.bufnr(file) ~= -1) then
    local function _9_(bufnr)
      return get_bufnr_links(link_type, bufnr)
    end
    return _9_(vim.uri_to_bufnr(vim.uri_from_fname(file)))
  else
    local file0 = io.open(file, "r"):read("*a")
    local parser = treesitter["get-neorg-file-parser"](file0)
    return get_links(parser, get_query(link_type), file0)
  end
end
local function get_local_footnotes()
  return get_bufnr_links("footnote", 0)
end
local function get_local_headings(level)
  return get_bufnr_links(string.format("heading%d", level), 0)
end
local function get_local_generics()
  return get_bufnr_links("generic", 0)
end
local function get_foreign_footnotes(path)
  return get_file_links("footnote", path)
end
local function get_foreign_headings(path, level)
  return get_file_links(string.format("heading%d", level), path)
end
return {["get-local-footnotes"] = get_local_footnotes, ["get-local-headings"] = get_local_headings, ["get-local-generics"] = get_local_generics, ["get-foreign-footnotes"] = get_foreign_footnotes, ["get-foreign-headings"] = get_foreign_headings}
