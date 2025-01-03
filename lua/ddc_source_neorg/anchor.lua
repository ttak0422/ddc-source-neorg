-- [nfnl] Compiled from fnl/ddc_source_neorg/anchor.fnl by https://github.com/Olical/nfnl, do not edit.
local ts = require("ddc_source_neorg.internal.treesitter")
local function get_anchors(bufnr_3f)
  local bufnr = (bufnr_3f or 0)
  local query = "(anchor_definition (link_description text: (paragraph) @anchor_name))"
  local anchors = {}
  local callback
  local function _1_(query0, id, node)
    if (query0.captures[id] == "anchor_name") then
      return table.insert(anchors, ts.get_node_text(node, bufnr))
    else
      return nil
    end
  end
  callback = _1_
  ts.norg.execute_query(query, callback)
  return anchors
end
return {get_anchors = get_anchors}
