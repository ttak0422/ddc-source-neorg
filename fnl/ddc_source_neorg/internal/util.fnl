; (bufnr?: number) -> number
(fn normalize_bufnr [bufnr?]
  (let [bufnr (or bufnr? 0)]
    (if (= bufnr 0)
        (vim.api.nvim_get_current_buf)
        bufnr)))

{: normalize_bufnr}
