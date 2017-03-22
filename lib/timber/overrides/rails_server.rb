require "rails/commands/server"

class ::Rails::Server < ::Rack::Server
  def initialize(*)
    raise "test"
    r = super
    raise "wtf"
    options[:log_to_stdout] = false
    r
  end

  private
    def log_to_stdout
    end
end