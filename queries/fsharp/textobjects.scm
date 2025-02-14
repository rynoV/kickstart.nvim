(declaration_expression
   (function_or_value_defn
      (function_declaration_left)
      body: (_) @function.inner)
   ) @function.outer

; A workaround for functions with record destructuring arguments not recognized as functions
(declaration_expression
   (function_or_value_defn
      (value_declaration_left
        (identifier_pattern
          (record_pattern)))
      body: (_) @function.inner)
   ) @function.outer

(member_defn
  (method_or_prop_defn
    ; Match the last child as the body
    (_) @function.inner .)) @function.outer
