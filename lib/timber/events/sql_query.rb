require "timber/event"

module Timber
  module Events
    # The SQL query event tracks sql queries to your database.
    #
    # @note This event should be installed automatically through integrations,
    #   such as the {Integrations::ActiveRecord::LogSubscriber} integration.
    class SQLQuery < Timber::Event
      MESSAGE_MAX_BYTES = 8192.freeze
      SQL_MAX_BYTES = 4096.freeze

      attr_reader :sql, :time_ms, :message

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        @message = normalizer.fetch!(:message, :string, :limit => MESSAGE_MAX_BYTES)
        @sql = normalizer.fetch!(:sql, :string, :limit => SQL_MAX_BYTES)
        @time_ms = normalizer.fetch!(:time_ms, :float, :precision => 6)
      end

      def to_hash
        @to_hash ||= Util::NonNilHashBuilder.build do |h|
          h.add(:sql, sql)
          h.add(:time_ms, time_ms)
        end
      end
      alias to_h to_hash

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def as_json(_options = {})
        {:sql_query => to_hash}
      end
    end
  end
end