require 'spec_helper'

describe Guard::CoffeeScript do

  before do
    Guard::CoffeeScript::Inspector.stub(:clean)
    Guard::CoffeeScript::Runner.stub(:run)
  end

  describe '#initialize' do
    context 'when no options are provided' do
      let(:guard) { Guard::CoffeeScript.new }

      it 'sets a default :wrap option' do
        guard.options[:bare].should be_false
      end

      it 'sets a default :shallow option' do
        guard.options[:shallow].should be_false
      end

      it 'sets a default :hide_success option' do
        guard.options[:hide_success].should be_false
      end
    end

    context 'with other options than the default ones' do
      let(:guard) { Guard::CoffeeScript.new(nil, { :output => 'output_folder', :bare => true, :shallow => true, :hide_success => true }) }

      it 'sets the provided :bare option' do
        guard.options[:bare].should be_true
      end

      it 'sets the provided :shallow option' do
        guard.options[:shallow].should be_true
      end

      it 'sets the provided :hide_success option' do
        guard.options[:hide_success].should be_true
      end
    end

    context 'with a input option' do
      let(:guard) { Guard::CoffeeScript.new(nil, { :input => 'app/coffeescripts' }) }

      it 'creates a watcher' do
        guard.should have(1).watchers
      end

      it 'watches all *.coffee files' do
        guard.watchers.first.pattern.should eql %r{app/coffeescripts/(.+\.coffee)}
      end
    end
  end

  describe '.run_all' do
    let(:guard) { Guard::CoffeeScript.new([Guard::Watcher.new('^x/(.*)\.coffee')]) }

    before do
      Dir.stub(:glob).and_return ['x/a.coffee', 'x/b.coffee', 'y/c.coffee']
    end

    it 'runs the run_on_change with all watched CoffeeScripts' do
      guard.should_receive(:run_on_change).with(['x/a.coffee', 'x/b.coffee'])
      guard.run_all
    end
  end

  describe '.run_on_change' do
    let(:guard) { Guard::CoffeeScript.new }

    before do
      guard.stub(:notify)
    end

    it 'passes the paths to the Inspector for cleanup' do
      Guard::CoffeeScript::Inspector.should_receive(:clean).with(['a.coffee', 'b.coffee'])
      guard.run_on_change(['a.coffee', 'b.coffee'])
    end

    it 'starts the Runner with the cleaned files' do
      Guard::CoffeeScript::Inspector.should_receive(:clean).with(['a.coffee', 'b.coffee']).and_return ['a.coffee']
      Guard::CoffeeScript::Runner.should_receive(:run).with(['a.coffee'], [], {
          :bare => false,
          :shallow => false,
          :hide_success => false }).and_return ['a.js']
      guard.run_on_change(['a.coffee', 'b.coffee'])
    end

    it 'notifies the other guards about the changed files' do
      Guard::CoffeeScript::Runner.should_receive(:run).and_return ['a.js', 'b.js']
      guard.should_receive(:notify).with(['a.js', 'b.js'])
      guard.run_on_change(['a.coffee', 'b.coffee'])
    end
  end
end
