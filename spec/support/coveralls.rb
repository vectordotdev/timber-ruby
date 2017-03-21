begin
  require 'coveralls'
  Coveralls.wear!
rescue LoadError
  # jruby does not include coveralls
end