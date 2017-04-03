module Timber
  module Util
    # @private
    module String
      UTF8 = "UTF-8".freeze

      # @private
      def self.normalize_to_utf8(string)
        if string.encoding.to_s == UTF8
          string
        else
          string.encode('UTF-8', {
            :invalid => :replace,
            :undef   => :replace,
            :replace => '?'
          })
        end
      end
    end
  end
end