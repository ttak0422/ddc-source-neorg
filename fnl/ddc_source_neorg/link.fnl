(import-macros {: style-text} :ddc_source_neorg.macro)
(local util (require :ddc_source_neorg.internal.util))
(local treesitter (require :ddc_source_neorg.internal.treesitter))

(local generic (style-text "
        [(_
          [(strong_carryover_set
             (strong_carryover
               name: (tag_name) @tag_name
               (tag_parameters) @title
               (#eq? @tag_name \"name\")))
           (weak_carryover_set
             (weak_carryover
               name: (tag_name) @tag_name
               (tag_parameters) @title
               (#eq? @tag_name \"name\")))]?
          title: (paragraph_segment) @title)
         (inline_link_target
           (paragraph) @title)]
      "))

(local (definition footnote)
       (let [template (style-text "
        (REPLACE_list
            (strong_carryover_set
                  (strong_carryover
                    name: (tag_name) @tag_name
                    (tag_parameters) @title
                    (#eq? @tag_name \"name\")))?
            .
            [(single_REPLACE
               (weak_carryover_set
                  (weak_carryover
                    name: (tag_name) @tag_name
                    (tag_parameters) @title
                    (#eq? @tag_name \"name\")))?
               (single_REPLACE_prefix)
               title: (paragraph_segment) @title)
             (multi_REPLACE
               (weak_carryover_set
                  (weak_carryover
                    name: (tag_name) @tag_name
                    (tag_parameters) @title
                    (#eq? @tag_name \"name\")))?
                (multi_REPLACE_prefix)
                  title: (paragraph_segment) @title)])
        ")]
         (values (string.gsub template :REPLACE :definition)
                 (string.gsub template :REPLACE :footnote))))

(local other-template (style-text "
            (%s
              [(strong_carryover_set
                 (strong_carryover
                   name: (tag_name) @tag_name
                   (tag_parameters) @title
                   (#eq? @tag_name \"name\")))
               (weak_carryover_set
                 (weak_carryover
                   name: (tag_name) @tag_name
                   (tag_parameters) @title
                   (#eq? @tag_name \"name\")))]?
              (%s_prefix)
              title: (paragraph_segment) @title)
        "))

(fn get-query [link-type]
  (case link-type
    :generic generic
    :definition definition
    :footnote footnote
    other (string.format other-template other other)))

(fn get-links [link-type bufnr?]
  (let [bufnr (util.normalize-bufnr bufnr?)
        query-string (get-query link-type)
        parser (treesitter.get-neorg-parser bufnr)]
    (case parser
      parser (let [links []
                   query (treesitter.parse-neorg-query query-string)
                   tree (. (parser:parse) 1)]
               (each [id node (query:iter_captures (tree:root) bufnr 0 -1)]
                 (if (= (. query.captures id) :title)
                     (-?> (treesitter.get-node-text node bufnr)
                          (string.gsub "\\" "")
                          (string.gsub "%s+" "")
                          (string.gsub "^%s" "")
                          ((fn [title]
                             (table.insert links title))))))
               links)
      _ [])))

(fn get-local-footnotes []
  (get-links :footnote 0))

(fn get-local-headings [level]
  (get-links (string.format "heading%d" level) 0))

(fn get-local-generics []
  (get-links :generic 0))

{: get-local-footnotes : get-local-headings : get-local-generics}
