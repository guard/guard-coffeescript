require 'spec_helper'

describe Guard::CoffeeScript::Runner do
  describe '#run' do
    let(:runner)  { Guard::CoffeeScript::Runner }
    let(:watcher) { Guard::Watcher.new('^(.*)\.coffee') }

    before do
      runner.stub(:compile).and_return ''
      FileUtils.stub(:mkdir_p)
      File.stub(:open)
    end

    it 'shows a start notification' do
      ::Guard::CoffeeScript::Formatter.should_receive(:info).once.with('Compile a.coffee, b.coffee', { :reset => true })
      ::Guard::CoffeeScript::Formatter.should_receive(:success).once.with('Successfully generated ')
      runner.run(['a.coffee', 'b.coffee'], [])
    end

    context 'without a nested directory' do
      let(:watcher) { Guard::Watcher.new(%r{src/.+\.coffee}) }

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

    context 'with the :bare option set to an array of filenames' do
      let(:watcher) { Guard::Watcher.new(%r{src/.+\.coffee}) }
      
      before do
        runner.unstub(:compile)
        ::CoffeeScript.stub(:compile)
        File.stub(:read) {|file| file}
      end

      after do
        runner.stub(:compile).and_return ''; ::CoffeeScript.unstub(:compile) 
      end

      it 'should compile files in the list without the outer function wrapper' do
        ::CoffeeScript.should_receive(:compile).with 'src/a.coffee', hash_including(:bare => true) 
        runner.run(['src/a.coffee', 'src/b.coffee'], [watcher], {:output => 'target', :bare => ['a.coffee']})
      end

      it 'should compile files not in the list with the outer function wrapper' do
        ::CoffeeScript.should_receive(:compile).with 'src/b.coffee', hash_including(:bare => false) 
        runner.run(['src/a.coffee', 'src/b.coffee'], [watcher], {:output => 'target', :bare => ['a.coffee']})
      end

    end

    context 'with the :shallow option set to false' do
      let(:watcher) { Guard::Watcher.new('^app/coffeescripts/(.*)\.coffee') }

      it 'compiles the CoffeeScripts to the output and creates nested directories' do
        FileUtils.should_receive(:mkdir_p).with("#{ @project_path }/javascripts/x/y")
        File.should_receive(:open).with("#{ @project_path }/javascripts/x/y/a.js", 'w')
        runner.run(['app/coffeescripts/x/y/a.coffee'], [watcher], { :output => 'javascripts', :shallow => false })
      end
    end

    context 'with the :shallow option set to true' do
      let(:watcher) { Guard::Watcher.new('^app/coffeescripts/(.*)\.coffee') }

      it 'compiles the CoffeeScripts to the output without creating nested directories' do
        FileUtils.should_receive(:mkdir_p).with("#{ @project_path }/javascripts")
        File.should_receive(:open).with("#{ @project_path }/javascripts/a.js", 'w')
        runner.run(['app/coffeescripts/x/y/a.coffee'], [watcher], { :output => 'javascripts', :shallow => true })
      end
    end

    context 'with compilation errors' do
      it 'shows the error messages' do
        runner.should_receive(:compile).and_raise ::CoffeeScript::CompilationError.new("Parse error on line 2: Unexpected 'UNARY'")
        ::Guard::CoffeeScript::Formatter.should_receive(:error).once.with("a.coffee: Parse error on line 2: Unexpected 'UNARY'")
        Guard::Notifier.should_receive(:notify).with("a.coffee: Parse error on line 2: Unexpected 'UNARY'", :title => 'CoffeeScript results', :image => :failed)
        runner.run(['a.coffee'], [watcher], { :output => 'javascripts' })
      end
    end

    context 'without compilation errors' do
      it 'shows a success messages' do
        runner.should_receive(:compile).with('a.coffee', { :output => 'javascripts' }).and_return ["OK", true]
        runner.should_receive(:notify_start).with(['a.coffee'], { :output => 'javascripts' })
        ::Guard::CoffeeScript::Formatter.should_receive(:success).once.with('Successfully generated javascripts/a.js')
        Guard::Notifier.should_receive(:notify).with('Successfully generated javascripts/a.js', :title => 'CoffeeScript results')
        runner.run(['a.coffee'], [watcher], { :output => 'javascripts' })
      end

      context 'with the :hide_success option set to true' do
        let(:watcher) { Guard::Watcher.new('^app/coffeescripts/(.*)\.coffee') }

        it 'compiles the CoffeeScripts to the output and creates nested directories' do
          FileUtils.should_receive(:mkdir_p).with("#{ @project_path }/javascripts/x/y")
          ::Guard::CoffeeScript::Formatter.should_not_receive(:success).with('Successfully generated javascripts/a.js')
          Guard::Notifier.should_not_receive(:notify).with('Successfully generated javascripts/a.js', :title => 'CoffeeScript results')
          runner.run(['app/coffeescripts/x/y/a.coffee'], [watcher], { :output => 'javascripts', :hide_success => true })
        end
      end
    end

  end
end
