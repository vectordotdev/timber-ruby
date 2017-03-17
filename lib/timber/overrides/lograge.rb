# Timber and lograge are not compatible installed together. Using lograge
# with the Timber.io *service* is perfectly fine, but not with the Timber *gem*.
begin
  require "lograge"

  module Lograge
    module_function

    def setup(app)
      return true
    end
  end
rescue Exception
end