require "timber/log_device/collector"
require "timber/log_device/installer"

require "logger"

module Timber
  module LogDevice

    ::Logger::LogDevice.send(:include, Installer)
  end
end
