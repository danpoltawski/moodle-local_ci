require 'coveralls'

SimpleCov.formatters = [
  Coveralls::SimpleCov::Formatter,
]
SimpleCov.add_group 'Bash Scripts', '\.sh$'
SimpleCov.add_filter '/myram/'
