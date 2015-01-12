require 'coffee_script'

module Guard
  class CoffeeScript
    module Runner
      class << self
        attr_accessor :last_run_failed

        # The CoffeeScript runner handles the CoffeeScript compilation,
        # creates nested directories and the output file, writes the result
        # to the console and triggers optional system notifications.
        #
        # @param [Array<String>] files the spec files or directories
        # @param [Array<Regexp>] patterns the patterns in the block
        # @param [Hash] options the options for the execution
        # @option options [String] :input the input directory
        # @option options [String] :output the output directory
        # @option options [Boolean] :bare do not wrap the output in a top level function
        # @option options [Boolean] :shallow do not create nested directories
        # @option options [Boolean] :hide_success hide success message notification
        # @option options [Boolean] :noop do not generate an output file
        # @option options [Boolean] :source_map generate the source map files
        # @return [Array<Array<String>, Boolean>] the result for the compilation run
        #
        def run(files, patterns, options = {})
          notify_start(files, options)
          changed_files, errors = compile_files(files, patterns, options)
          notify_result(changed_files, errors, options)
          [changed_files, errors.empty?]
        end

        # The remove function deals with CoffeeScript file removal by
        # locating the output javascript file and removing it.
        #
        # @param [Array<String>] files the spec files or directories
        # @param [Array<Regexp>] patterns the patterns in the block
        # @param [Hash] options the options for the removal
        # @option options [String] :output the output directory
        # @option options [Boolean] :shallow do not create nested directories
        #
        def remove(files, patterns, options = {})
          removed_files = []
          directories   = detect_nested_directories(files, patterns, options)

          directories.each do |directory, scripts|
            scripts.each do |file|
              javascript = javascript_file_name(file, directory)
              if File.exist?(javascript)
                FileUtils.remove_file(javascript)
                removed_files << javascript
              end
            end
          end

          return unless removed_files.length > 0

          message = "Removed #{ removed_files.join(', ') }"
          Formatter.success(message)
          Formatter.notify(message, title: 'CoffeeScript results')
        end

        private

        # Generates a start compilation notification.
        #
        # @param [Array<String>] files the generated files
        # @param [Hash] options the options for the execution
        # @option options [Boolean] :noop do not generate an output file
        #
        def notify_start(files, options)
          message = options[:message] || (options[:noop] ? 'Verify ' : 'Compile ') + files.join(', ')
          Formatter.info(message, reset: true)
        end

        # Compiles all CoffeeScript files and writes the JavaScript files.
        #
        # @param [Array<String>] files the files to compile
        # @param [Hash] options the options for the execution
        # @return [Array<Array<String>, Array<String>] the result for the compilation run
        #
        def compile_files(files, patterns, options)
          errors        = []
          changed_files = []
          directories   = detect_nested_directories(files, patterns, options)

          directories.each do |directory, scripts|
            scripts.each do |file|
              begin
                js, map = compile(file, options)
                changed_files << write_javascript_file(js, map, file, directory, options)

              rescue RuntimeError, ::CoffeeScript::EngineError, ::CoffeeScript::CompilationError => e
                error_message = file + ': ' + e.message.to_s

                if options[:error_to_js]
                  js_error_message = "throw \"#{ error_message }\";"
                  changed_files << write_javascript_file(js_error_message, nil, file, directory, options)
                end

                errors << error_message
                Formatter.error(error_message)
              end
            end
          end

          [changed_files.flatten.compact, errors]
        end

        # Compile the CoffeeScript and generate the source map.
        #
        # @param [String] filename the CoffeeScript file n
        # @param [Hash] options the options for the execution
        # @option options [Boolean] :source_map generate the source map files
        # @return [Array<String, String>] the JavaScript source and the source map
        #
        def compile(filename, options)
          file = File.read(filename)
          file_options = options_for_file(filename, options)

          if options[:source_map]
            file_options.merge! options_for_source_map(filename, options)
            result = ::CoffeeScript.compile(file, file_options)
            fail 'CoffeeScript.compile returned nil' if result.nil?
            js, map = result['js'], result['v3SourceMap']
          else
            js  = ::CoffeeScript.compile(file, file_options)
          end

          [js, map]
        end

        # Gets the CoffeeScript compilation options.
        #
        # @param [String] file the CoffeeScript file
        # @param [Hash] options the options for the execution of all files
        # @option options [Boolean] :bare do not wrap the output in a top level function
        # @return [Hash] options for a particular file's execution
        #
        def options_for_file(file, options)
          file_options = options.clone

          # if :bare was provided an array of filenames, check for file's inclusion
          if file_options[:bare].respond_to? :include?
            filename            = file[/([^\/]*)\.(?:coffee|coffee\.md|litcoffee)$/]
            file_options[:bare] = file_options[:bare].include?(filename)
          end

          file_options[:literate] = true if file[/\.(?:coffee\.md|litcoffee)$/]

          file_options
        end

        # Gets the CoffeeScript source map options.
        #
        # @param [String] filename the CoffeeScript filename
        # @param [Hash] options the options for the execution
        #
        def options_for_source_map(filename, options)
          # if :input was provided, make all filenames relative to that
          filename = Pathname.new(filename).relative_path_from(Pathname.new(options[:input])).to_s if options[:input]

          {
            sourceMap: true,
            generatedFile: filename.gsub(/((?:js\.)?(?:coffee|coffee\.md|litcoffee))$/, 'js'),
            sourceFiles: [filename],
            sourceRoot: options[:source_root] || options[:input] || ''
          }
        end

        # Analyzes the CoffeeScript compilation output and creates the
        # nested directories and writes the output file.
        #
        # @param [String] js the JavaScript content
        # @param [String] map the source map content
        # @param [String] file the CoffeeScript file name
        # @param [String] directory the output directory
        # @param [Hash] options the options for the execution
        # @option options [Boolean] :noop do not generate an output file
        # @return [String] the JavaScript file name
        #
        def write_javascript_file(js, map, file, directory, options)
          directory = Dir.pwd if !directory || directory.empty?
          filename = javascript_file_name(file, directory)

          return filename if options[:noop]

          if options[:source_map]
            map_name = filename + '.map'
            js += "\n//# sourceMappingURL=#{File.basename(map_name)}\n"
          end

          FileUtils.mkdir_p(File.expand_path(directory)) unless File.directory?(directory)
          File.open(File.expand_path(filename), 'w') { |f| f.write(js) }

          if options[:source_map]
            File.open(File.expand_path(map_name), 'w') { |f| f.write(map) }
            [filename, map_name]
          else
            filename
          end
        end

        # Calculates the output filename from the coffescript filename and
        # the output directory
        #
        # @param [string] file the CoffeeScript file name
        # @param [String] directory the output directory
        #
        def javascript_file_name(file, directory)
          File.join(directory, File.basename(file.gsub(/((?:js\.)?(?:coffee|coffee\.md|litcoffee))$/, 'js')))
        end

        # Detects the output directory for each CoffeeScript file. Builds
        # the product of all patterns and assigns to each directory
        # the files to which it belongs to.
        #
        # @param [Array<String>] files the CoffeeScript files
        # @param [Array<Regexp>] patterns the patterns in the block
        # @param [Hash] options the options for the execution
        # @option options [String] :output the output directory
        # @option options [Boolean] :shallow do not create nested directories
        #
        def detect_nested_directories(files, patterns, options)
          return { options[:output] => files } if options[:shallow]

          directories = {}

          patterns.product(files).each do |pattern, file|
            next unless (matches = file.match(pattern))

            target = matches[1] ? File.join(options[:output], File.dirname(matches[1])).gsub(/\/\.$/, '') : options[:output] || File.dirname(file)
            if directories[target]
              directories[target] << file
            else
              directories[target] = [file]
            end
          end

          directories
        end

        # Writes console and system notifications about the result of the compilation.
        #
        # @param [Array<String>] changed_files the changed JavaScript files
        # @param [Array<String>] errors the error messages
        # @param [Hash] options the options for the execution
        # @option options [Boolean] :hide_success hide success message notification
        # @option options [Boolean] :noop do not generate an output file
        #
        def notify_result(changed_files, errors, options = {})
          if !errors.empty?
            self.last_run_failed = true
            Formatter.notify(errors.join("\n"), title: 'CoffeeScript results', image: :failed, priority: 2)
          elsif !options[:hide_success] || last_run_failed
            self.last_run_failed = false
            message = "Successfully #{ options[:noop] ? 'verified' : 'generated' } #{ changed_files.join(', ') }"
            Formatter.success(message)
            Formatter.notify(message, title: 'CoffeeScript results')
          end
        end
      end
    end
  end
end
