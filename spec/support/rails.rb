module Support
  module Rails
    def reset_rails_environment
      if ::Rails.version =~ /^3.0/
        ::Rails::Application.class_eval do
          @@instance = nil
        end
      end
      Object.send(:remove_const, :RailsApp)
      ::Rails.application = nil
    end
  end
end

RSpec.configure do |config|
  config.include Support::Rails
end
