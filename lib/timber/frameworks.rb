# Attempt to require Rails. We can not list it as a gem
# dependency because we want to support multiple frameworks.
begin
  require("rails")
  Config.logger.debug("Rails successfully required")
rescue LoadError
  Config.logger.debug("Rails could not be required")
end

if defined?(Rails)
  require 'timber/frameworks/rails'
end
