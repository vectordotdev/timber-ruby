require "action_controller"

ActionController::Base.prepend_view_path("#{File.dirname(__FILE__)}/rails/templates")
ActionController::Base.logger = Rails.logger