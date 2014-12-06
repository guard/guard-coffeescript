RSpec.describe Guard::CoffeeScript do
  let(:input) { 'app/assets/javascripts' }
  let(:output) { 'app/assets/javascripts' }
  let(:pattern) { %r{^app/assets/javascripts/(.+\.(?:coffee|coffee\.md|litcoffee))$} }
  let(:extra_options) { {} }
  let(:options) { { input: input, output: output, patterns: [pattern] }.merge(extra_options) }

  subject { described_class.new(options) }

  let(:runner) { described_class::Runner }
  let(:inspector) { described_class::Inspector }

  let(:defaults) { described_class::DEFAULT_OPTIONS }

  before do
    allow(inspector).to receive(:clean)
    allow(runner).to receive(:run)
    allow(runner).to receive(:remove)
  end

  describe '#initialize' do
    context 'when no options are provided' do
      specify { expect(subject.options).to include(bare: false) }
      specify { expect(subject.options).to include(shallow: false) }
      specify { expect(subject.options).to include(hide_success: false) }
      specify { expect(subject.options).to include(noop: false) }
      specify { expect(subject.options).to include(all_on_start: false) }
      specify { expect(subject.options).to include(source_map: false) }
    end

    context 'with options besides the defaults' do
      let(:extra_options) do
        {
          output: 'output_folder',
          bare: true,
          shallow: true,
          hide_success: true,
          all_on_start: true,
          noop: true,
          source_map: true
        }
      end

      specify { expect(subject.options).to include(bare: true) }
      specify { expect(subject.options).to include(shallow: true) }
      specify { expect(subject.options).to include(hide_success: true) }
      specify { expect(subject.options).to include(noop: true) }
      specify { expect(subject.options).to include(all_on_start: true) }
      specify { expect(subject.options).to include(source_map: true) }
    end

    context 'without an input option' do
      let(:input) { nil }
      specify { expect { subject }.to raise_error(/:input option not provided/) }
    end

    context 'with a input option' do
      let(:output) { 'app/coffeescripts' }
      let(:pattern) { %r{^app/coffeescripts/(.+\.(?:coffee|coffee\.md|litcoffee))$} }

      it 'watches all *.{coffee,coffee.md,litcoffee} files' do
        expect(subject.patterns.first).to eql pattern
      end

      context 'without an output option' do
        let(:input) { 'app/coffeescripts' }
        let(:output) { nil }
        specify { expect(subject.options).to include(output: 'app/coffeescripts') }
      end

      context 'with an output option' do
        let(:output) { 'public/javascripts' }
        specify { expect(subject.options).to include(output: 'public/javascripts') }
      end
    end
  end

  describe '#start' do
    it 'calls #run_all' do
      expect(subject).not_to receive(:run_all)
      subject.start
    end

    context 'with the :all_on_start option' do
      let(:extra_options) { { all_on_start: true } }

      it 'calls #run_all' do
        expect(subject).to receive(:run_all)
        subject.start
      end
    end
  end

  describe '#run_all' do
    let(:pattern) { /^x\/.+\.(?:coffee|coffee\.md|litcoffee)$/ }

    before do
      allow(Dir).to receive(:glob).and_return ['x/a.coffee', 'x/b.coffee', 'y/c.coffee', 'x/d.coffeeemd', 'x/e.litcoffee']
    end

    it 'runs the run_on_modifications with all watched CoffeeScripts' do
      expect(subject).to receive(:run_on_modifications).with(['x/a.coffee', 'x/b.coffee', 'x/e.litcoffee'])
      subject.run_all
    end
  end

  describe '#run_on_modifications' do
    it 'throws :task_has_failed when an error occurs' do
      expected_opts = defaults.merge(
        input: 'app/assets/javascripts',
        output: 'app/assets/javascripts',
        patterns: [pattern]
      )
      expect(inspector).to receive(:clean).with(['a.coffee', 'b.coffee']).and_return ['a.coffee']
      expect(runner).to receive(:run).with(['a.coffee'], [pattern], expected_opts).and_return [[], false]
      expect { subject.run_on_modifications(['a.coffee', 'b.coffee']) }.to throw_symbol :task_has_failed
    end

    it 'starts the Runner with the cleaned files' do
      expected_opts = defaults.merge(
        input: 'app/assets/javascripts',
        output: 'app/assets/javascripts',
        patterns: [pattern]
      )
      expect(inspector).to receive(:clean).with(['a.coffee', 'b.coffee']).and_return ['a.coffee']
      expect(runner).to receive(:run).with(['a.coffee'], [pattern], expected_opts).and_return [['a.js'], true]
      subject.run_on_modifications(['a.coffee', 'b.coffee'])
    end
  end

  describe '#run_on_removals' do
    it 'cleans the paths accepting missing files' do
      expect(inspector).to receive(:clean).with(['a.coffee', 'b.coffee'],  missing_ok: true)
      subject.run_on_removals(['a.coffee', 'b.coffee'])
    end

    it 'removes the files' do
      expect(inspector).to receive(:clean).and_return ['a.coffee', 'b.coffee']
      expect(runner).to receive(:remove).with(['a.coffee', 'b.coffee'], subject.patterns, subject.options)
      subject.run_on_removals(['a.coffee', 'b.coffee'])
    end
  end
end
