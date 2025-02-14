(function_or_value_defn
  (function_declaration_left)
  body: (_) @function.inner) @function.outer

; A workaround for functions with destructuring/pattern arguments not recognized as functions
(function_or_value_defn
  (value_declaration_left
    (identifier_pattern
      (long_identifier_or_op)
      (_)))
  body: (_) @function.inner) @function.outer

(member_defn
  (method_or_prop_defn
    ; Match whatever is after the args as the body. This handles comments which may follow the body and mess things up
    args: (_)
    (_) @function.inner) @function.outer)

