module Guard
  class CoffeeScript
    # The inspector verifies of the changed paths are valid
    # for Guard::CoffeeScript.
    #
    module Inspector
      class << self
        # Clean the changed paths and return only valid
        # CoffeeScript files.
        #
        # @param [Array<String>] paths the changed paths
        # @param [Hash] options the clean options
        # @option options [String] :missing_ok don't remove missing files from list
        # @return [Array<String>] the valid spec files
        #
        def clean(paths, options = {})
          paths.uniq!
          paths.compact!
          paths.select { |p| coffee_file?(p, options) }
        end

        private

        # Tests if the file is valid.
        #
        # @param [String] path the file
        # @param [Hash] options the clean options
        # @option options [String] :missing_ok don't remove missing files from list
        # @return [Boolean] when the file valid
        #
        def coffee_file?(path, options)
          path =~ /\.(?:coffee|coffee\.md|litcoffee)$/ && (options[:missing_ok] || File.exist?(path))
        end
      end
    end
  end
end
