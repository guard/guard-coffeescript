require 'guard/compat/plugin'

module Guard
  # The CoffeeScript guard that gets notifications about the following
  # Guard events: `start`, `stop`, `reload`, `run_all` and `run_on_change`.
  #
  class CoffeeScript < Plugin
    require 'guard/coffeescript/formatter'
    require 'guard/coffeescript/inspector'
    require 'guard/coffeescript/runner'

    DEFAULT_OPTIONS = {
      bare: false,
      shallow: false,
      hide_success: false,
      noop: false,
      error_to_js: false,
      all_on_start: false,
      source_map: false
    }

    # Initialize Guard::CoffeeScript.
    #

    # @param [Hash] options the options for the Guard
    # @option options [String] :input the input directory
    # @option options [String] :output the output directory
    # @option options [Array<Guard::Watcher>] :watchers the watchers in the Guard block
    # @option options [Boolean] :bare do not wrap the output in a top level function
    # @option options [Boolean] :shallow do not create nested directories
    # @option options [Boolean] :hide_success hide success message notification
    # @option options [Boolean] :all_on_start generate all JavaScripts files on start
    # @option options [Boolean] :noop do not generate an output file
    # @option options [Boolean] :source_map generate the source map files
    #

    attr_reader :patterns

    def initialize(options = {})
      defaults = DEFAULT_OPTIONS.clone

      @patterns = options.dup.delete(:patterns) || []

      msg = 'Invalid :patterns argument. Expected: Array, got %s'
      fail ArgumentError, format(msg, @patterns.inspect) unless @patterns.is_a?(Array)

      msg = ':input option not provided (see current template Guardfile)'
      fail msg unless options[:input]

      options[:output] = options[:input] unless options[:output]

      super(defaults.merge(options))
    end

    # Gets called once when Guard starts.
    #
    # @raise [:task_has_failed] when stop has failed
    #
    def start
      run_all if options[:all_on_start]
    end

    # Gets called when all files should be regenerated.
    #
    # @raise [:task_has_failed] when stop has failed
    #
    def run_all
      found = Dir.glob('**{,/*/**}/*.{coffee,coffee.md,litcoffee}')
      found.select! do |file|
        @patterns.any? do |pattern|
          pattern.match(file)
        end
      end

      run_on_modifications(found)
    end

    # Gets called when watched paths and files have changes.
    #
    # @param [Array<String>] paths the changed paths and files
    # @raise [:task_has_failed] when stop has failed
    #
    def run_on_modifications(paths)
      _changed_files, success = Runner.run(Inspector.clean(paths), @patterns, options)

      throw :task_has_failed unless success
    end

    # Called on file(s) deletions that the Guard watches.
    #
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def run_on_removals(paths)
      Runner.remove(Inspector.clean(paths, missing_ok: true), @patterns, options)
    end
  end
end
