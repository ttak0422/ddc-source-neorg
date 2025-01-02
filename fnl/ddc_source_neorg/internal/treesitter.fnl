(local util (require :ddc_source_neorg.internal.util))

(fn parse-query [language query]
  (if vim.treesitter.query.parse
      (vim.treesitter.query.parse language query)
      (vim.treesitter.parse_query language query)))

(fn get-bufnr-parser [language bufnr]
  (vim.treesitter.get_parser bufnr language))

(fn get-file-parser [language file]
  (vim.treesitter.get_string_parser file language))

(fn execute-query [language query callback bufnr]
  (let [query (parse-query language query)
        parser (get-bufnr-parser language bufnr)]
    (if parser
        (do
          (let [root (: (. (parser:parse) 1) :root)]
            (each [id node (query:iter_captures root bufnr)
                   &until (callback query id node)]
              (lua "-- nop")))
          true)
        false)))

(fn get-bufnr-node-text [node bufnr]
  (case [node bufnr]
    [node source] (let [(start-row start-col) (node:start)
                        eof-row (vim.api.nvim_buf_line_count source)
                        (end-row end-col) (let [(row col) (node:end_)]
                                            (if (>= row eof-row)
                                                (values (- eof-row 1) -1)
                                                (values row col)))]
                    (if (>= start-row eof-row)
                        ""
                        (let [lines (vim.api.nvim_buf_get_text source start-row
                                                               start-col end-row
                                                               end-col {})]
                          (table.concat lines "\\n"))))
    _ ""))

(fn get-file-node-text [node path]
  (let [(_ _ start_bytes) (node:start)
        (_ _ end_bytes) (node:end_)]
    (string.sub path (+ start_bytes 1) end_bytes)))

(fn get-node-text [node src]
  (case (type src)
    :string (get-file-node-text node src)
    :number (get-bufnr-node-text node src)
    _ ""))

{:parse-neorg-query (fn [query]
                      (parse-query :norg query))
 :get-neorg-bufnr-parser (fn [bufnr?]
                           (get-bufnr-parser :norg
                                             (util.normalize-bufnr bufnr?)))
 :get-neorg-file-parser (fn [file]
                          (get-file-parser :norg file))
 :execute-neorg-query (fn [query callback bufnr?]
                        (execute-query :norg query callback
                                       (util.normalize-bufnr bufnr?)))
 :get-node-text (fn [node bufnr?]
                  (get-node-text node (util.normalize-bufnr bufnr?)))}
