begin
  require "rails/commands/server"

  class ::Rails::Server < ::Rack::Server
    private
      def log_to_stdout
      end
  end
rescue Exception
end