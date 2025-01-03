call ddc#custom#patch_global('ui', 'native')

call ddc#custom#patch_global('sources', ['around'])
call ddc#custom#patch_filetype(['norg'], {
      \ 'sources': ['neorg', 'around'],
      \ })

call ddc#custom#patch_global('sourceOptions', {
      \ 'around': {
      \   'mark': 'A',
      \ },
      \ 'neorg': {
      \   'mark': 'N',
      \   'minAutoCompleteLength': 0,
      \ }})

call ddc#custom#patch_global('sourceOptions', {
      \ '_': {
      \   'matchers': ['matcher_head'],
      \   'sorters': ['sorter_rank']},
      \ })

call ddc#enable()
