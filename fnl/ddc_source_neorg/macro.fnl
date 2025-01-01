; HACK: style text at compile time
(fn style-text [str]
  (-> str
      (string.gsub "\n" " ")
      (string.gsub "%s+" " ")
      (string.gsub "^%s" "")
      (string.gsub "%s$" "")))

{: style-text }
