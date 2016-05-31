# Attempt to require Rails. We can not list it as a gem
# dependency because we want to support multiple frameworks.
begin
  require("rails")
  Timber::Config.logger.debug("Rails successfully required")
rescue LoadError
  Timber::Config.logger.debug("Rails could not be required")
end

if defined?(Rails)
  require 'timber/frameworks/rails'
end
