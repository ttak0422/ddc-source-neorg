(local shared (require :ddc_source_neorg.link.shared))

(fn get_headings [path level]
  (shared.get_links (string.format "heading%d" level) path))

(fn get_footnotes [path]
  (shared.get_links :footnote path))

(fn get_generics [path]
  (shared.get_links :generic path))

{: get_headings : get_footnotes : get_generics}
