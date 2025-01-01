-- [nfnl] Compiled from fnl/ddc_source_neorg/macro.fnl by https://github.com/Olical/nfnl, do not edit.
local function style_text(str)
  return string.gsub(string.gsub(string.gsub(string.gsub(str, "\n", " "), "%s+", " "), "^%s", ""), "%s$", "")
end
return {["style-text"] = style_text}
