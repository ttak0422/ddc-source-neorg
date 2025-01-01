(local treesitter (require :ddc_source_neorg.internal.treesitter))

(fn get-anchors [bufnr?]
  (let [query " (anchor_definition (link_description text: (paragraph) @anchor_name))"
        anchors []
        callback (fn [query id node]
                   (if (= (. query.captures id) :anchor_name)
                       (table.insert anchors
                                     (treesitter.get-node-text node bufnr?))))]
    (treesitter.execute-neorg-query query callback)
    anchors))

{: get-anchors}
