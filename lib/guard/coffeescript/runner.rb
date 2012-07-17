require 'coffee_script'

module Guard
  class CoffeeScript
    module Runner
      class << self

        # The CoffeeScript runner handles the CoffeeScript compilation,
        # creates nested directories and the output file, writes the result
        # to the console and triggers optional system notifications.
        #
        # @param [Array<String>] paths the spec files or directories
        # @param [Array<Guard::Watcher>] watchers the Guard watchers in the block
        # @param [Hash] options the options for the execution
        # @option options [String] :input the input directory
        # @option options [String] :output the output directory
        # @option options [Boolean] :bare do not wrap the output in a top level function
        # @option options [Boolean] :shallow do not create nested directories
        # @option options [Boolean] :hide_success hide success message notification
        # @option options [Boolean] :noop do not generate an output file
        # @return [Array<Array<String>, Boolean>] the result for the compilation run
        #
        def run(files, watchers, options = { })
          notify_start(files, options)
          changed_files, errors = compile_files(files, watchers, options)
          notify_result(changed_files, errors, options)

          [changed_files, errors.empty?]
        end

        # The remove function deals with CoffeeScript file removal by
        # locating the output javascript file and removing it.
        #
        # @param [Array<String>] paths the spec files or directories
        # @param [Array<Guard::Watcher>] watchers the Guard watchers in the block
        # @param [Hash] options the options for the removal
        # @option options [String] :output the output directory
        # @option options [Boolean] :shallow do not create nested directories
        #
        def remove(files, watchers, options = { })
          removed_files = []
          directories   = detect_nested_directories(watchers, files, options)

          directories.each do |directory, scripts|
            scripts.each do |file|
              javascript = javascript_file_name(file, directory)
              if File.exists?(javascript)
                FileUtils.remove_file(javascript)
                removed_files << javascript
              end
            end
          end

          message = "Removed #{ removed_files.join(', ') }"
          Formatter.success(message)
          Formatter.notify(message, :title => 'CoffeeScript results')
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
          Formatter.info(message, :reset => true)
        end

        # Compiles all CoffeeScript files and writes the JavaScript files.
        #
        # @param [Array<String>] files the files to compile
        # @param [Array<Guard::Watcher>] watchers the Guard watchers in the block
        # @param [Hash] options the options for the execution
        # @return [Array<Array<String>, Array<String>] the result for the compilation run
        #
        def compile_files(files, watchers, options)
          errors        = []
          changed_files = []
          directories   = detect_nested_directories(watchers, files, options)

          directories.each do |directory, scripts|
            scripts.each do |file|
              begin
                content = compile(file, options)
                changed_files << write_javascript_file(content, file, directory, options)
              rescue => e
                error_message = file + ': ' + e.message.to_s

                if options[:error_to_js]
                  js_error_message = "throw \"#{ error_message }\";"
                  changed_files << write_javascript_file(js_error_message, file, directory, options)
                end

                errors << error_message
                Formatter.error(error_message)
              end
            end
          end

          [changed_files.compact, errors]
        end

        # Compile the CoffeeScripts
        #
        # @param [String] file the CoffeeScript file
        # @param [Hash] options the options for the execution
        #
        def compile(file, options)
          file_options = options_for_file(file, options)
          ::CoffeeScript.compile(File.read(file), file_options)
        end

        # Gets the CoffeeScript compilation options.
        #
        # @param [String] file the CoffeeScript file
        # @param [Hash] options the options for the execution
        # @option options [Boolean] :bare do not wrap the output in a top level function
        #
        def options_for_file(file, options)
          return options unless options[:bare].respond_to? :include?

          file_options        = options.clone
          filename            = file[/([^\/]*)\.coffee/]
          file_options[:bare] = file_options[:bare].include?(filename)

          file_options
        end

        # Analyzes the CoffeeScript compilation output and creates the
        # nested directories and writes the output file.
        #
        # @param [String] content the JavaScript content
        # @param [String] file the CoffeeScript file name
        # @param [String] directory the output directory
        # @param [Hash] options the options for the execution
        # @option options [Boolean] :noop do not generate an output file
        #
        def write_javascript_file(content, file, directory, options)
          directory = Dir.pwd if !directory || directory.empty?
          FileUtils.mkdir_p(File.expand_path(directory)) if !File.directory?(directory) && !options[:noop]
          filename = javascript_file_name(file, directory)
          File.open(File.expand_path(filename), 'w') { |f| f.write(content) } if !options[:noop]

          filename
        end

        # Calculates the output filename from the coffescript filename and
        # the output directory
        #
        # @param [string] file the CoffeeScript file name
        # @param [String] directory the output directory
        #
        def javascript_file_name(file, directory)
          File.join(directory, File.basename(file.gsub(/(js\.coffee|coffee)$/, 'js')))
        end

        # Detects the output directory for each CoffeeScript file. Builds
        # the product of all watchers and assigns to each directory
        # the files to which it belongs to.
        #
        # @param [Array<Guard::Watcher>] watchers the Guard watchers in the block
        # @param [Array<String>] files the CoffeeScript files
        # @param [Hash] options the options for the execution
        # @option options [String] :output the output directory
        # @option options [Boolean] :shallow do not create nested directories
        #
        def detect_nested_directories(watchers, files, options)
          return { options[:output] => files } if options[:shallow]

          directories = { }

          watchers.product(files).each do |watcher, file|
            if matches = file.match(watcher.pattern)
              target = matches[1] ? File.join(options[:output], File.dirname(matches[1])).gsub(/\/\.$/, '') : options[:output] || File.dirname(file)
              if directories[target]
                directories[target] << file
              else
                directories[target] = [file]
              end
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
        def notify_result(changed_files, errors, options = { })
          if !errors.empty?
            Formatter.notify(errors.join("\n"), :title => 'CoffeeScript results', :image => :failed, :priority => 2)
          elsif !options[:hide_success]
            message = "Successfully #{ options[:noop] ? 'verified' : 'generated' } #{ changed_files.join(', ') }"
            Formatter.success(message)
            Formatter.notify(message, :title => 'CoffeeScript results')
          end
        end

      end
    end
  end
end
