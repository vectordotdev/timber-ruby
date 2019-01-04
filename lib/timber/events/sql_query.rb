require 'timber/util'
require 'timber/event'

module Timber
  module Events
    # The SQL query event tracks sql queries to your database.
    #
    # @note This event should be installed automatically through integrations,
    #   such as the {Integrations::ActiveRecord::LogSubscriber} integration.
    class SQLQuery < Timber::Event
      MESSAGE_MAX_BYTES = 8192.freeze
      SQL_MAX_BYTES = 4096.freeze

      attr_reader :sql, :duration_ms, :message

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        @message = normalizer.fetch!(:message, :string, :limit => MESSAGE_MAX_BYTES)
        @sql = normalizer.fetch!(:sql, :string, :limit => SQL_MAX_BYTES)
        @duration_ms = normalizer.fetch!(:duration_ms, :float, :precision => 6)
      end

      def metadata
        hash = Util::NonNilHashBuilder.build do |h|
          h.add(:sql, sql)
          h.add(:duration_ms, duration_ms)
        end

        {
          event: {
            sql_query_executed: hash
          }
        }
      end
    end
  end
end
