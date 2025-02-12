(declaration_expression
   (function_or_value_defn
        (function_declaration_left)
        body: (_) @function.inner)
   ) @function.outer

(member_defn
  (method_or_prop_defn
    (declaration_expression) @function.inner)) @function.outer
