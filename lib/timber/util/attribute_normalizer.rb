module Timber
  module Util
    # @private
    #
    # The purpose of this class is to normalize parameters passed to events
    # and contexts. Timber validates a rigid JSON schema against the defined
    # Timber log event JSON schema. This normalization process ensures the
    # data passed to events and contexts conforms to this structure.
    class AttributeNormalizer
      def initialize(attributes)
        @attributes = attributes
      end

      def fetch!(key, type, options = {})
        v = fetch(key, type, options)
        if v.nil?
          raise ArgumentError.new("The #{key.inspect} attribute is required")
        end
        v
      end

      def fetch(key, type, options = {})
        v = @attributes[key]

        if blank?(v)
          options[:default] || nil
        else
          case type
          when :array
            if !v.is_a?(Array)
              raise ArgumentError.new("The #{key.inspect} attribute must be a list if provided")
            end

            v

          when :float
            v = v.to_f

            if options[:precision]
              v = v.round(options[:precision])
            end

            v

          when :hash
            if options[:sanitize]
              v = Util::Hash.sanitize_keys(v, options[:sanitize])
            end

            v = Util::Hash.jsonify(v)

            if v == {}
              nil
            else
              v
            end

          when :integer
            v.to_i

          when :string
            v = v.to_s

            if options[:limit]
              v = v.byteslice(0, options[:limit])
            end

            if options[:upcase]
              v = v.upcase
            end

            v

          when :symbol
            v.to_sym

          else
            raise ArgumentError.new("Unknown normalization type #{type}")
          end
        end
      end

      private
        def blank?(v)
          v.nil? || (v.respond_to?(:length) && v.length == 0)
        end
    end
  end
end