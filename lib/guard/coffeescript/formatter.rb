module Guard
  class CoffeeScript
    # The Guard::CoffeeScript formatter collects console and
    # system notification methods and enhances them with
    # some color information.
    #
    module Formatter
      class << self
        # Print an info message to the console.
        #
        # @param [String] message the message to print
        # @param [Hash] options the output options
        # @option options [Boolean] :reset reset the UI
        #
        def info(message, options = {})
          Compat::UI.info(message, options)
        end

        # Print a debug message to the console.
        #
        # @param [String] message the message to print
        # @param [Hash] options the output options
        # @option options [Boolean] :reset reset the UI
        #
        def debug(message, options = {})
          Compat::UI.debug(message, options)
        end

        # Print a red error message to the console.
        #
        # @param [String] message the message to print
        # @param [Hash] options the output options
        # @option options [Boolean] :reset reset the UI
        #
        def error(message, options = {})
          Compat::UI.error(color(message, ';31'), options)
        end

        # Print a green success message to the console.
        #
        # @param [String] message the message to print
        # @param [Hash] options the output options
        # @option options [Boolean] :reset reset the UI
        #
        def success(message, options = {})
          stamped_message = "#{Time.now.strftime('%r')} #{message}"
          Compat::UI.info(color(stamped_message, ';32'), options)
        end

        # Outputs a system notification.
        #
        # @param [String] message the message to print
        # @param [Hash] options the output options
        # @option options [Symbol, String] :image the image to use, either :failed, :pending or :success, or an image path
        # @option options [String] :title the title of the system notification
        #
        def notify(message, options = {})
          Compat::UI.notify(message, options)
        end

        private

        # Print a info message to the console.
        #
        # @param [String] text the text to colorize
        # @param [String] color_code the color code
        #
        def color(text, color_code)
          Compat::UI.send(:color_enabled?) ? "\e[0#{ color_code }m#{ text }\e[0m" : text
        end
      end
    end
  end
end
