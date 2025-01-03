-- [nfnl] Compiled from fnl/ddc_source_neorg/link/foreign.fnl by https://github.com/Olical/nfnl, do not edit.
local shared = require("ddc_source_neorg.link.shared")
local function get_headings(path, level)
  return shared.get_links(string.format("heading%d", level), path)
end
local function get_footnotes(path)
  return shared.get_links("footnote", path)
end
local function get_generics(path)
  return shared.get_links("generic", path)
end
return {get_headings = get_headings, get_footnotes = get_footnotes, get_generics = get_generics}
