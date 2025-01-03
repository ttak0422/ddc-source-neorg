(local util (require :ddc_source_neorg.internal.util))
(local ts (require :ddc_source_neorg.internal.treesitter))

(local generic "
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
  (inline_link_target (paragraph) @title)]")

(local (definition footnote)
       (let [template "
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
     title: (paragraph_segment) @title)])"]
         (values (string.gsub template :REPLACE :definition)
                 (string.gsub template :REPLACE :footnote))))

(local other_template "
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
  title: (paragraph_segment) @title)")

(fn get_query [link_type]
  (case link_type
    :generic generic
    :definition definition
    :footnote footnote
    other (string.format other_template other other)))

(fn parse_links [parser? query_string src]
  (case parser?
    parser (let [links []
                 query (ts.norg.parse_query query_string)
                 tree (. (parser:parse) 1)]
             (each [id node (query:iter_captures (tree:root) src 0 -1)]
               (if (= (. query.captures id) :title)
                   (-?> (ts.get_node_text node src)
                        (string.gsub "\\" "")
                        (string.gsub "%s+" "")
                        (string.gsub "^%s" "")
                        ((fn [title]
                           (table.insert links title))))))
             links)
    _ []))

(fn get_bufnr_links [link_type bufnr]
  (let [parser (ts.norg.get_parser bufnr)]
    (parse_links parser (get_query link_type) bufnr)))

(fn get_file_links [link_type file]
  (if (not= (vim.fn.bufnr file) -1)
      (-> file
          (vim.uri_from_fname)
          (vim.uri_to_bufnr)
          ((fn [bufnr] (get_bufnr_links link_type bufnr))))
      (let [file (-> (io.open file :r)
                     (: :read :*a))
            parser (ts.norg.get_parser file)]
        (parse_links parser (get_query link_type) file))))

; (link_type: string, source: string | number?) -> string[]
(fn get_links [link_type source]
  (case (type source)
    :string (get_file_links link_type source)
    :number (get_bufnr_links link_type (util.normalize_bufnr source))
    _ []))

{: get_links}
