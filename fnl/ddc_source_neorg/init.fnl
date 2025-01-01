(fn cb [id value]
  (vim.api.nvim_call_function "ddc#callback" [id value]))

(fn get-runtime-files [path]
  (icollect [_ name (pairs (vim.api.nvim_get_runtime_file path true))]
    (vim.fn.fnamemodify name ":t:r")))

;;; bindings ;;;

; get current buffer : (id: string) => [ id: string, path: string ]
(fn get-current-buffer [id]
  (cb id (vim.api.nvim_buf_get_name 0)))

; get languages : (id: string) => [ id: string, { languages: string[] } ]
(fn get-language-list [id]
  (let [syntax (get-runtime-files :syntax/*.vim)
        after-syntax (get-runtime-files :after/syntax/*.vim)
        parser (get-runtime-files :parser/*.so)
        files []]
    (each [_ fs (ipairs [syntax after-syntax parser])]
      (each [_ f (ipairs fs)]
        (table.insert files f)))
    (cb id {:languages files})))

; get current workspace : (id: string) → [ id: string, { name: string, path: string } ]
(fn get-current-workspace [id]
  (let [neorg (require :neorg)
        dirman (neorg.modules.get_module :core.dirman)
        workspace (dirman.get_current_workspace)
        name (. workspace 1)
        path (: (. workspace 2) :tostring)]
    (cb id {: name : path})))

; get anchors : (id: string) -> [ id: string, anchors: string[] ]
(fn get-anchor-list [id]
  (let [anchor (require :ddc_source_neorg.anchor)
        anchors (anchor.get-anchors)]
    (cb id anchors)))

; get local footnotes : (id: string) -> [ id: string, footnotes: string[] ]
(fn get-local-footnote-list [id]
  (let [link (require :ddc_source_neorg.link)
        links (link.get-local-footnotes)]
    (cb id links)))

; get local headings : (id: string, level: 1 | 2 | 3 | 4 | 5 | 6) -> [ id: string, headings: string[] ]
(fn get-local-heading-list [id level]
  (let [link (require :ddc_source_neorg.link)
        links (link.get-local-headings level)]
    (cb id links)))

{: get-current-buffer
 : get-language-list
 : get-current-workspace
 : get-anchor-list
 : get-local-footnote-list
 : get-local-heading-list}
