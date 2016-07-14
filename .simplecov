require 'coveralls'

SimpleCov.formatters = [
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter,
]
SimpleCov.add_group 'Bash Scripts', '\.sh$'
