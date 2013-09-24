require 'spec_helper'

describe Guard::CoffeeScript::Runner do
  let(:runner) { Guard::CoffeeScript::Runner }
  let(:watcher) { Guard::Watcher.new('^(.*)\.coffee') }
  let(:formatter) { Guard::CoffeeScript::Formatter }

  before do
    runner.stub(:compile).and_return ''
    formatter.stub(:notify)

    FileUtils.stub(:mkdir_p)
    FileUtils.stub(:remove_file)
    File.stub(:open)
  end

  describe '#run' do
    context 'without the :noop option' do
      it 'shows a start notification' do
        formatter.should_receive(:info).once.with('Compile a.coffee, b.coffee', { :reset => true })
        formatter.should_receive(:success).once.with('Successfully generated ')
        runner.run(['a.coffee', 'b.coffee'], [])
      end
    end

    context 'with the :noop option' do
      it 'shows a start notification' do
        formatter.should_receive(:info).once.with('Verify a.coffee, b.coffee', { :reset => true })
        formatter.should_receive(:success).once.with('Successfully verified ')
        runner.run(['a.coffee', 'b.coffee'], [], { :noop => true })
      end
    end

    context 'without a nested directory' do
      let(:watcher) { Guard::Watcher.new(%r{src/.+\.coffee}) }

      context 'without the :noop option' do
        it 'compiles the CoffeeScripts to the output and replace .coffee with .js' do
          FileUtils.should_receive(:mkdir_p).with("#{ @project_path }/target")
          File.should_receive(:open).with("#{ @project_path }/target/a.js", 'w')
          runner.run(['src/a.coffee'], [watcher], { :output => 'target' })
        end

        it 'compiles the CoffeeScripts to the output and replace .js.coffee with .js' do
          FileUtils.should_receive(:mkdir_p).with("#{ @project_path }/target")
          File.should_receive(:open).with("#{ @project_path }/target/a.js", 'w')
          runner.run(['src/a.js.coffee'], [watcher], { :output => 'target' })
        end
      end

      context 'without the :output option' do
        it 'compiles the CoffeeScripts to the same dir like the file and replace .coffee with .js' do
          FileUtils.should_receive(:mkdir_p).with("#{ @project_path }/src")
          File.should_receive(:open).with("#{ @project_path }/src/a.js", 'w')
          runner.run(['src/a.coffee'], [watcher])
        end

        it 'compiles the CoffeeScripts to the same dir like the file and replace .js.coffee with .js' do
          FileUtils.should_receive(:mkdir_p).with("#{ @project_path }/src")
          File.should_receive(:open).with("#{ @project_path }/src/a.js", 'w')
          runner.run(['src/a.js.coffee'], [watcher])
        end
      end

      context 'with the :noop option' do
        it 'does not write the output file' do
          FileUtils.should_not_receive(:mkdir_p).with("#{ @project_path }/target")
          File.should_not_receive(:open).with("#{ @project_path }/target/a.js", 'w')
          runner.run(['src/a.coffee'], [watcher], { :output => 'target', :noop => true })
        end
      end

      context 'with the :source_map option' do
        it 'compiles the source map to the same dir like the file and replace .coffee with .js.map' do
          FileUtils.should_receive(:mkdir_p).with("#{ @project_path }/src")
          File.should_receive(:open).with("#{ @project_path }/src/a.js.map", 'w')
          runner.run(['src/a.coffee'], [watcher], :source_map => true)
        end

        it 'compiles the source map to the same dir like the file and replace .js.coffee with .js.map' do
          FileUtils.should_receive(:mkdir_p).with("#{ @project_path }/src")
          File.should_receive(:open).with("#{ @project_path }/src/a.js.map", 'w')
          runner.run(['src/a.js.coffee'], [watcher], :source_map => true)
        end

      end
    end

    context 'with the :bare option set to an array of filenames' do
      let(:watcher) { Guard::Watcher.new(%r{src/.+\.coffee}) }

      before do
        runner.unstub(:compile)
        ::CoffeeScript.stub(:compile)
        File.should_receive(:read).with('src/a.coffee').and_return 'a = -> 1'
        File.should_receive(:read).with('src/b.coffee').and_return 'b = -> 2'
      end

      it 'should compile files in the list without the outer function wrapper' do
        ::CoffeeScript.should_receive(:compile).with 'a = -> 1', hash_including(:bare => true)
        runner.run(['src/a.coffee', 'src/b.coffee'], [watcher], { :output => 'target', :bare => ['a.coffee'] })
      end

      it 'should compile files not in the list with the outer function wrapper' do
        ::CoffeeScript.should_receive(:compile).with 'b = -> 2', hash_including(:bare => false)
        runner.run(['src/a.coffee', 'src/b.coffee'], [watcher], { :output => 'target', :bare => ['a.coffee'] })
      end
    end

    context 'with the :shallow option set to false' do
      let(:watcher) { Guard::Watcher.new('^app/coffeescripts/(.*)\.coffee') }

      it 'compiles the CoffeeScripts to the output and creates nested directories' do
        FileUtils.should_receive(:mkdir_p).with("#{ @project_path }/javascripts/x/y")
        File.should_receive(:open).with("#{ @project_path }/javascripts/x/y/a.js", 'w')
        runner.run(['app/coffeescripts/x/y/a.coffee'], [watcher], { :output => 'javascripts', :shallow => false })
      end

      context 'with the :source_map option' do
        it 'generates the source map to the output and creates nested directories' do
          FileUtils.should_receive(:mkdir_p).with("#{ @project_path }/javascripts/x/y")
          File.should_receive(:open).with("#{ @project_path }/javascripts/x/y/a.js.map", 'w')
          runner.run(['app/coffeescripts/x/y/a.coffee'], [watcher], { :output => 'javascripts', :shallow => false, :source_map => true })
        end
      end
    end

    context 'with the :shallow option set to true' do
      let(:watcher) { Guard::Watcher.new('^app/coffeescripts/(.*)\.coffee') }

      it 'compiles the CoffeeScripts to the output without creating nested directories' do
        FileUtils.should_receive(:mkdir_p).with("#{ @project_path }/javascripts")
        File.should_receive(:open).with("#{ @project_path }/javascripts/a.js", 'w')
        runner.run(['app/coffeescripts/x/y/a.coffee'], [watcher], { :output => 'javascripts', :shallow => true })
      end

      context 'with the :source_map option' do
        it 'generates the source map to the output without creating nested directories' do
          FileUtils.should_receive(:mkdir_p).with("#{ @project_path }/javascripts")
          File.should_receive(:open).with("#{ @project_path }/javascripts/a.js.map", 'w')
          runner.run(['app/coffeescripts/x/y/a.coffee'], [watcher], { :output => 'javascripts', :shallow => true, :source_map => true })
        end
      end
    end

    context 'with the :source_map option' do
      before do
        runner.unstub(:compile)
        ::CoffeeScript.stub(:compile)
        File.stub(:read) { |file| file }
      end

      after do
        runner.stub(:compile).and_return ''
        ::CoffeeScript.unstub(:compile)
      end

      it 'compiles with source map file options set' do
        ::CoffeeScript.should_receive(:compile).with 'src/a.coffee', hash_including({
          :sourceMap => true,
          :generatedFile => 'a.js',
          :sourceFiles => ['a.coffee'],
          :sourceRoot => 'src',
        })
        runner.run(['src/a.coffee'], [watcher], { :output => 'target', :source_map => true, :input => 'src' })
      end

      it 'accepts a different source_root' do
        ::CoffeeScript.should_receive(:compile).with 'src/a.coffee', hash_including(:sourceRoot => 'foo')
        runner.run(['src/a.coffee'], [watcher], { :output => 'target', :source_map => true, :source_root => 'foo' })
      end
    end

    context 'with compilation errors' do
      context 'without the :noop option' do
        it 'shows the error messages' do
          runner.should_receive(:compile).and_raise ::CoffeeScript::CompilationError.new("Parse error on line 2: Unexpected 'UNARY'")
          formatter.should_receive(:error).once.with("a.coffee: Parse error on line 2: Unexpected 'UNARY'")
          formatter.should_receive(:notify).with("a.coffee: Parse error on line 2: Unexpected 'UNARY'",
                                                 :title => 'CoffeeScript results',
                                                 :image => :failed,
                                                 :priority => 2)
          runner.run(['a.coffee'], [watcher], { :output => 'javascripts' })
        end
      end

      context 'with the :noop option' do
        it 'shows the error messages' do
          runner.should_receive(:compile).and_raise ::CoffeeScript::CompilationError.new("Parse error on line 2: Unexpected 'UNARY'")
          formatter.should_receive(:error).once.with("a.coffee: Parse error on line 2: Unexpected 'UNARY'")
          formatter.should_receive(:notify).with("a.coffee: Parse error on line 2: Unexpected 'UNARY'",
                                                 :title => 'CoffeeScript results',
                                                 :image => :failed,
                                                 :priority => 2)
          runner.run(['a.coffee'], [watcher], { :output => 'javascripts', :noop => true })
        end
      end

      context 'with the :error_to_js option' do
        it 'write the error message as javascript file' do
          runner.should_receive(:compile).and_raise ::CoffeeScript::CompilationError.new("Parse error on line 2: Unexpected 'UNARY'")
          runner.should_receive(:write_javascript_file).once.with("throw \"a.coffee: Parse error on line 2: Unexpected 'UNARY'\";", nil, 'a.coffee', 'javascripts', kind_of(Hash))
          runner.run(['a.coffee'], [watcher], { :output => 'javascripts', :error_to_js => true })
        end

      end
    end

    context 'without compilation errors' do
      context 'without the :noop option' do
        it 'shows a success messages' do
          formatter.should_receive(:success).once.with('Successfully generated javascripts/a.js')
          formatter.should_receive(:notify).with('Successfully generated javascripts/a.js',
                                                 :title => 'CoffeeScript results')
          runner.run(['a.coffee'], [watcher], { :output => 'javascripts' })
        end
      end

      context 'with the :noop option' do
        it 'shows a success messages' do
          formatter.should_receive(:success).once.with('Successfully verified javascripts/a.js')
          formatter.should_receive(:notify).with('Successfully verified javascripts/a.js',
                                                 :title => 'CoffeeScript results')
          runner.run(['a.coffee'], [watcher], { :output => 'javascripts',
                                                :noop => true })
        end
      end

      context 'with the :hide_success option set to true' do
        let(:watcher) { Guard::Watcher.new('^app/coffeescripts/(.*)\.coffee') }

        it 'does not show the success message' do
          formatter.should_not_receive(:success).with('Successfully generated javascripts/a.js')
          formatter.should_not_receive(:notify).with('Successfully generated javascripts/a.js',
                                                     :title => 'CoffeeScript results')
          runner.run(['app/coffeescripts/x/y/a.coffee'], [watcher], { :output => 'javascripts',
                                                                      :hide_success => true })
        end
      end
    end

    context 'with :hide_success over multiple runs' do
      it 'shows the failure message every time' do
        runner.should_receive(:compile).twice.and_raise ::CoffeeScript::CompilationError.new("Parse error on line 2: Unexpected 'UNARY'")
        formatter.should_receive(:error).twice.with("a.coffee: Parse error on line 2: Unexpected 'UNARY'")
        formatter.should_receive(:notify).twice.with("a.coffee: Parse error on line 2: Unexpected 'UNARY'",
                                               :title => 'CoffeeScript results',
                                               :image => :failed,
                                               :priority => 2)

        2.times { runner.run(['a.coffee'], [watcher], { :output => 'javascripts' }) }
      end

      it 'shows the success message only when previous attempt was failure' do
        runner.should_receive(:compile).and_raise ::CoffeeScript::CompilationError.new("Parse error on line 2: Unexpected 'UNARY'")
        runner.run(['a.coffee'], [watcher], { :output => 'javascripts',
                                              :hide_success => true })

        runner.stub(:compile).and_return ''
        formatter.should_receive(:success).with('Successfully generated javascripts/a.js')
        formatter.should_receive(:notify).with('Successfully generated javascripts/a.js',
                                                   :title => 'CoffeeScript results')
        runner.run(['a.coffee'], [watcher], { :output => 'javascripts',
                                              :hide_success => true })
      end
    end

  end

  describe '#remove' do
    let(:watcher) { Guard::Watcher.new(%r{src/.+\.coffee}) }

    before do
      File.should_receive(:exists?).with('target/a.js').and_return true
      File.should_receive(:exists?).with('target/b.js').and_return true
    end

    it 'removes the files' do
      FileUtils.should_receive(:remove_file).with('target/a.js')
      FileUtils.should_receive(:remove_file).with('target/b.js')
      runner.remove(['src/a.coffee', 'src/b.coffee'], [watcher], { :output => 'target' })
    end

    it 'shows a notification' do
      formatter.should_receive(:success).once.with('Removed target/a.js, target/b.js')
      formatter.should_receive(:notify).with('Removed target/a.js, target/b.js',
                                             :title => 'CoffeeScript results')

      runner.remove(['src/a.coffee', 'src/b.coffee'], [watcher], { :output => 'target' })
    end
  end
end
