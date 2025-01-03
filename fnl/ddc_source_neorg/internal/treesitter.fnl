(local util (require :ddc_source_neorg.internal.util))

; (language: string, query: string) -> Query?
(fn parse_query [language query]
  (if vim.treesitter.query.parse
      (vim.treesitter.query.parse language query)
      (vim.treesitter.parse_query language query)))

; (language: string, bufnr: number) -> TSParser?
(fn get_bufnr_parser [language bufnr]
  (vim.treesitter.get_parser bufnr language))

; (language: string, file: string) -> TSParser?
(fn get_file_parser [language file]
  (vim.treesitter.get_string_parser file language))

; (language: string, source: string | number?) -> TSNode?
(fn get_parser [language source]
  (case (type source)
    :string (get_file_parser language source)
    :number (get_bufnr_parser language (util.normalize_bufnr source))
    _ nil))

; (language: string, query: string, callback: (query: TSQuery, id: number, node: TSNode) -> boolean, bufnr: number) -> boolean
(fn execute_query [language query callback bufnr]
  (let [query (parse_query language query)
        parser (get_bufnr_parser language bufnr)]
    (if parser
        (do
          (let [root (: (. (parser:parse) 1) :root)]
            (each [id node (query:iter_captures root bufnr)
                   &until (callback query id node)]
              (lua "-- nop")))
          true)
        false)))

; (node: TSNode, bufnr: number) -> string
(fn get_bufnr_node_text [node bufnr]
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

; (node: TSNode, path: string) -> string
(fn get_file_node_text [node path]
  (let [(_ _ start_bytes) (node:start)
        (_ _ end_bytes) (node:end_)]
    (string.sub path (+ start_bytes 1) end_bytes)))

; (node: TSNode, soruce: string | number?) -> string
(fn get_node_text [node source]
  (case (type source)
    :string (get_file_node_text node source)
    :number (get_bufnr_node_text node (util.normalize_bufnr source))
    _ ""))

(let [norg {:get_parser (fn [source] (get_parser :norg source))
            :parse_query (fn [query]
                           (parse_query :norg query))
            :execute_query (fn [query callback bufnr?]
                             (execute_query :norg query callback
                                            (util.normalize_bufnr bufnr?)))}]
  {: norg : get_node_text})
