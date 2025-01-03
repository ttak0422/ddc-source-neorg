(local ts (require :ddc_source_neorg.internal.treesitter))

; (bufnr?: number) -> string[]
(fn get_anchors [bufnr?]
  (let [query "(anchor_definition (link_description text: (paragraph) @anchor_name))"
        anchors []
        callback (fn [query id node]
                   (if (= (. query.captures id) :anchor_name)
                       (table.insert anchors (ts.get_node_text node bufnr?))))]
    (ts.norg.execute_query query callback)
    anchors))

{: get_anchors}
