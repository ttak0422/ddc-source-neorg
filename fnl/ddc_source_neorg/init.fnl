(fn cb [id value]
  (vim.api.nvim_call_function "ddc#callback" [id value]))

(fn get_runtime_files [path]
  (icollect [_ name (pairs (vim.api.nvim_get_runtime_file path true))]
    (vim.fn.fnamemodify name ":t:r")))

;;; bindings ;;;
(local anchor (require :ddc_source_neorg.anchor))
(local link (require :ddc_source_neorg.link))

; get current buffer : (id: string) => [ id: string, path: string ]
(fn current_buffer [id]
  (cb id (vim.api.nvim_buf_get_name 0)))

; get current workspace : (id: string) → [ id: string, { name: string, path: string } ]
(fn current_workspace [id]
  (let [neorg (require :neorg)
        dirman (neorg.modules.get_module :core.dirman)
        workspace (dirman.get_current_workspace)
        name (. workspace 1)
        path (: (. workspace 2) :tostring)]
    (cb id {: name : path})))

; get languages : (id: string) => [ id: string, languages: string[] ]
(fn language_list [id]
  (let [syntax (get_runtime_files :syntax/*.vim)
        after-syntax (get_runtime_files :after/syntax/*.vim)
        parser (get_runtime_files :parser/*.so)
        languages []]
    (each [_ fs (ipairs [syntax after-syntax parser])]
      (each [_ f (ipairs fs)]
        (table.insert languages f)))
    (cb id languages)))

; get anchors : (id: string) -> [ id: string, anchors: string[] ]
(fn anchor_list [id]
  (cb id (anchor.get_anchors)))

(local local_link
       (let [
             ; get local headings : (id: string, level: 1 | 2 | 3 | 4 | 5 | 6) -> [ id: string, headings: string[] ]
             heading_list (fn [id level]
                            (cb id (link.local.get_headings level)))
             ; get local footnotes : (id: string) -> [ id: string, footnotes: string[] ]
             footnote_list (fn [id]
                             (cb id (link.local.get_footnotes)))
             ; get local generic links : (id: string) -> [ id: string, links: string[] ]
             generic_list (fn [id]
                            (cb id (link.local.get_generics)))]
         {: heading_list : footnote_list : generic_list}))

(local foreign_link
       (let [
             ; get foreign headings : (id: string, path: string, level: 1 | 2 | 3 | 4 | 5 | 6) -> [ id: string, headings: string[] ]
             heading_list (fn [id path level]
                            (cb id (link.foreign.get_headings path level)))
             ; get foreign footnotes : (id: string, path: string) -> [ id: string, footnotes: string[] ]
             footnote_list (fn [id path]
                             (cb id (link.foreign.get_footnotes path)))
             ; get foreign generic links : (id: string, path: string) -> [ id: string, links: string[] ]
             generic_list (fn [id path]
                            (cb id (link.foreign.get_generics path)))]
         {: heading_list : footnote_list : generic_list}))

{: current_buffer
 : current_workspace
 : language_list
 : anchor_list
 :local local_link
 :foreign foreign_link}
