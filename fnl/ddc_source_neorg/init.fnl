(fn get-runtime-files [path]
  (icollect [_ name (pairs (vim.api.nvim_get_runtime_file path true))]
    (vim.fn.fnamemodify name ":t:r")))

(fn get-language-list [id]
  (let [syntax (get-runtime-files :syntax/*.vim)
        after-syntax (get-runtime-files :after/syntax/*.vim)
        parser (get-runtime-files :parser/*.so)
        files []]
    (each [_ fs (ipairs [syntax after-syntax parser])]
      (each [_ f (ipairs fs)]
        (table.insert files f)))
    (vim.api.nvim_call_function "ddc#callback" [id {:languages files}])))

{: get-language-list}
