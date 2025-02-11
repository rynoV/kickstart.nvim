; vim: set filetype=query :
([
  (line_comment)
  (block_comment_content)
] @injection.content
  (#set! injection.language "comment"))

; This breaks stuff for some reason, seems like the xml parser errors
 ;( (line_comment) @injection.content
 ;  (#lua-match? @injection.content "^///")
 ;  (#offset! @injection.content 0 3 0 0)
 ;  (#set! injection.language "xml")
 ;  (#set! injection.combined)
 ;  )
 ;
