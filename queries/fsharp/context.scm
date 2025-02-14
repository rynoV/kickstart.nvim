(function_or_value_defn
   (function_declaration_left)
   body: (_) @context.end
   ) @context

; A workaround for functions with destructuring/pattern arguments not recognized as functions
(function_or_value_defn
  (value_declaration_left
    (identifier_pattern
      (long_identifier_or_op)
      (_)))
  body: (_) @context.end) @context

(member_defn
  (method_or_prop_defn
    ; Match the last child as the body
    (_) @context.end .)) @context

(type_definition
  ([
   (record_type_defn
     block: (_) @context.end)
   (union_type_defn
     block: (_) @context.end)
   (anon_type_defn
     block: (_) @context.end)
  ])) @context
