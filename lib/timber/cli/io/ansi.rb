module Timber
  class CLI
    class IO
      module ANSI
        def self.colorize(text, color)
          return text if Gem.win_platform?

          code =
            case color
            when :blue then 34
            when :red then 31
            when :green then 32
            when :yellow then 33
            else 0
            end

          "\e[#{code}m#{text}\e[0m"
        end
      end
    end
  end
end