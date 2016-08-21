module Timber
  module Contexts
    class Organization < Context
      ROOT_KEY = :organization.freeze
      VERSION = 1.freeze

      attr_reader :organization

      def id
        return @id if defined?(@id)
        @id = organization.respond_to?(:id) ? organization.id : nil
      end

      def name
        return @name if defined?(@name)
        @name = organization.respond_to?(:name) ? organization.name : nil
      end

      def valid?
        !organization.nil?
      end

      private
        def json_payload
          @json_payload ||= Macros::DeepMerger.merge({
            _root_key => {
              # order is relevant for logfmt styling
              :id => id,
              :name => name
            }
          }, super)
        end
    end
  end
end
