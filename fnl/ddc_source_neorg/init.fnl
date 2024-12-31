(fn get-runtime-files [path]
  (icollect [_ name (pairs (vim.api.nvim_get_runtime_file path true))]
    (vim.fn.fnamemodify name ":t:r")))

;;; bindings ;;;

; get current buffer : (id: string) => [ id: string, path: string ]
(fn get-current-buffer [id]
  (vim.api.nvim_call_function "ddc#callback" [id (vim.api.nvim_buf_get_name 0)]))

; get languages : (id: string) => [ id: string, { languages: string[] } ]
(fn get-language-list [id]
  (let [syntax (get-runtime-files :syntax/*.vim)
        after-syntax (get-runtime-files :after/syntax/*.vim)
        parser (get-runtime-files :parser/*.so)
        files []]
    (each [_ fs (ipairs [syntax after-syntax parser])]
      (each [_ f (ipairs fs)]
        (table.insert files f)))
    (vim.api.nvim_call_function "ddc#callback" [id {:languages files}])))

; get current workspace : (id: string) → [ id: string, { name: string, path: string } ]
(fn get-current-workspace [id]
  (let [neorg (require :neorg)
        dirman (neorg.modules.get_module :core.dirman)
        workspace (dirman.get_current_workspace)
        name (. workspace 1)
        path (: (. workspace 2) :tostring)]
    (vim.api.nvim_call_function "ddc#callback" [id {: name : path}])))

{: get-current-buffer : get-language-list : get-current-workspace}
