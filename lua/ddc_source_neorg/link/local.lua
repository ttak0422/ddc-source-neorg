-- [nfnl] Compiled from fnl/ddc_source_neorg/link/local.fnl by https://github.com/Olical/nfnl, do not edit.
local shared = require("ddc_source_neorg.link.shared")
local function get_headings(level)
  return shared.get_links(string.format("heading%d", level), 0)
end
local function get_footnotes()
  return shared.get_links("footnote", 0)
end
local function get_generics()
  return shared.get_links("generic", 0)
end
return {get_headings = get_headings, get_footnotes = get_footnotes, get_generics = get_generics}
