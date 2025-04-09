return {
  s('fun', { t 'fun ', i(1, '()'), t ' -> ', i(0) }),
  s('rec', { t 'type ', i(1, 'Name'), t ' = {', i(0), t '}' }),
  s('uni', { t 'type ', i(1, 'Name'), (t { ' =', '\t| ' }), i(0) }),
}
