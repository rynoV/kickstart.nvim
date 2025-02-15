[
  (function_or_value_defn)
  ; In some cases the declaration expression isn't parsed immediately
  (ERROR (value_declaration_left))
  (ERROR (function_declaration_left))
  (fun_expression)
  (member_defn)
  (module_defn)
  (type_definition)
  (for_expression)
  (while_expression)
  (try_expression)
  ; For this to work best, it's recommended not to use the "Cramped" fsharp_multiline_bracket_style setting of fantomas,
  ; because that uses irregular alignment (for example 4 spaces plus 1 for the list items). Note "Cramped" is the default
  (list_expression)
  (array_expression)
  (brace_expression)
  (brace_expression
    (with_field_expression) @indent.begin)
  (anon_record_expression)
  (anon_record_expression
    (with_field_expression) @indent.begin)
] @indent.begin

; These seem like they're going to be tricky. Same for function application across multiple lines
; ((ce_expression
;    block: (_) @indent.begin))

(
 (if_expression
   then: (_) @indent.end) @indent.begin
  (#set! indent.immediate 1)
)

(
 (elif_expression) @indent.branch
  (#set! indent.immediate 1)
)

(
 (rule) @indent.begin
  (#set! indent.immediate 1)
)
