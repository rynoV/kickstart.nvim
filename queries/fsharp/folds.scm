[
  (function_or_value_defn)
  (fun_expression)
  (module_defn)
  (member_defn)
  (type_definition)
  (ce_expression)
  (for_expression)
  (while_expression)
  (try_expression) ; Try expressions don't have nice labels, so comments can easily mess up folds if we made this more complicated
  (match_expression)
  (rule)
  (list_expression)
  (array_expression)
] @fold

(if_expression
  (elif_expression) @fold
  )

(if_expression
  then: (_) @fold)

(if_expression
  else: (_) @fold)

((import_decl)*) @fold
