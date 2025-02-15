(function_or_value_defn
   body: (_) @context.end
   ) @context

(fun_expression
  (_) ; Arguments
  (_) @context.end) @context

(member_defn
  (method_or_prop_defn
    ; Match whatever is after the args as the body. This handles comments which may follow the body and mess things up
    args: (_)
    (_) @context.end)) @context

(type_definition
  ([
   (record_type_defn
     block: (_) @context.end)
   (union_type_defn
     block: (_) @context.end)
   (anon_type_defn
     block: (_) @context.end)
  ])) @context

(ce_expression
  .
  (_)
  .
  (_) @context.end) @context

(for_expression
  (_)
  (_)
  (_) @context.end) @context

(while_expression
  (_)
  (_) @context.end) @context

(try_expression) @context

(match_expression
  (rules) @context.end) @context

(rule
  pattern: (_)
  (_) @context.end) @context
