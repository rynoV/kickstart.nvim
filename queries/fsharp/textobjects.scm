(declaration_expression
   (function_or_value_defn
        (function_declaration_left)
        body: (_) @function.inner)
   ) @function.outer

(member_defn
  (method_or_prop_defn
    ; Match the last child as the body
    (_) @function.inner .)) @function.outer
