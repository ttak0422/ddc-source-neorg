(local util (require :ddc_source_neorg.internal.util))
(local treesitter (require :ddc_source_neorg.internal.treesitter))

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

(local other-template "
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

(fn get-query [link-type]
  (case link-type
    :generic generic
    :definition definition
    :footnote footnote
    other (string.format other-template other other)))

(fn get-links [parser? query-string src]
  (case parser?
    parser (let [links []
                 query (treesitter.parse-neorg-query query-string)
                 tree (. (parser:parse) 1)]
             (each [id node (query:iter_captures (tree:root) src 0 -1)]
               (if (= (. query.captures id) :title)
                   (-?> (treesitter.get-node-text node src)
                        (string.gsub "\\" "")
                        (string.gsub "%s+" "")
                        (string.gsub "^%s" "")
                        ((fn [title]
                           (table.insert links title))))))
             links)
    _ []))

(fn get-bufnr-links [link-type bufnr?]
  (let [bufnr (util.normalize-bufnr bufnr?)
        parser (treesitter.get-neorg-bufnr-parser bufnr)]
    (get-links parser (get-query link-type) bufnr)))

(fn get-file-links [link-type file]
  (if (not= (vim.fn.bufnr file) -1)
      (-> file
          (vim.uri_from_fname)
          (vim.uri_to_bufnr)
          ((fn [bufnr] (get-bufnr-links link-type bufnr))))
      (let [file (-> (io.open file :r)
                     (: :read :*a))
            parser (treesitter.get-neorg-file-parser file)]
        (get-links parser (get-query link-type) file))))

(fn get-local-footnotes []
  (get-bufnr-links :footnote 0))

(fn get-local-headings [level]
  (get-bufnr-links (string.format "heading%d" level) 0))

(fn get-local-generics []
  (get-bufnr-links :generic 0))

(fn get-foreign-footnotes [path]
  (get-file-links :footnote path))

(fn get-foreign-headings [path level]
  (get-file-links (string.format "heading%d" level) path))

(fn get-foreign-generics [path]
  (get-file-links :generic path))

{: get-local-footnotes
 : get-local-headings
 : get-local-generics
 : get-foreign-footnotes
 : get-foreign-headings
 : get-foreign-generics}
