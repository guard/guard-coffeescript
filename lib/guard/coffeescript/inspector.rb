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
        # @return [Array<String>] the valid spec files
        #
        def clean(paths)
          paths.uniq!
          paths.compact!
          paths.select { |p| coffee_file?(p) }
        end

        private

        # Tests if the file is valid.
        #
        # @param [String] file the file
        # @return [Boolean] when the file valid
        #
        def coffee_file?(path)
          path =~ /.coffee$/ && File.exists?(path)
        end

      end
    end
  end
end
