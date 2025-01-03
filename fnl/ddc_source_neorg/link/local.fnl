(local shared (require :ddc_source_neorg.link.shared))

(fn get_headings [level]
  (shared.get_links (string.format "heading%d" level) 0))

(fn get_footnotes []
  (shared.get_links :footnote 0))

(fn get_generics []
  (shared.get_links :generic 0))

{: get_headings : get_footnotes : get_generics}
