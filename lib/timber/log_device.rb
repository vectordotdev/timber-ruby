require "log_device/collector"
require "log_device/installer"

require "logger"

module Timber
  module LogDevice

    ::Logger::LogDevice.send(:include, Installer)
  end
end
