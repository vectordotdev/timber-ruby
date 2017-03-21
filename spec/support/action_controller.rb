begin
  require "action_controller"
rescue LoadError
end

if defined?(::ActionController::Base)
  ::ActionController::Base.prepend_view_path("#{File.dirname(__FILE__)}/rails/templates")
end