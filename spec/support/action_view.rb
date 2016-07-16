require "action_view"

# Needed for the ActionView::LogSubscriber. If a logger is not present, nothing will be logged.
ActionView::Base.logger = Rails.logger if ActionView::Base.respond_to?(:logger=)