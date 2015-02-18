RSpec.describe Guard::CoffeeScript::Runner do
  let(:runner) { Guard::CoffeeScript::Runner }
  let(:pattern) { %r{spec/fixtures/.+\.coffee$} }
  let(:formatter) { Guard::CoffeeScript::Formatter }

  before do
    allow(formatter).to receive(:notify)

    Guard::CoffeeScript::Runner.last_run_failed = false
  end
  after do
    FileUtils.rm_rf "#{@project_path}/tmp" if Dir.exist? "#{@project_path}/tmp"
  end

  describe 'run script with pre processing instruction' do
    before { runner.run(["#{@project_path}/spec/fixtures/script_with_pre_processing.coffee"], [pattern], options) }
    context 'no preprocessing option present' do
      let(:options) { {output: 'tmp'} }
      it do
        file = File.read("#{@project_path}/tmp/script_with_pre_processing.js")
        expect(file).to match(/alert\('raw coffee beans'\);/)
      end
    end
    context 'with lambda preprocessing' do
      let(:options) { {output: 'tmp', pre_process: ->(file) { file.gsub(/raw coffee beans/, 'grinded coffee') }} }
      it do
        file = File.read("#{@project_path}/tmp/script_with_pre_processing.js")
        expect(file).to match(/alert\('grinded coffee'\);/)
      end
    end
    context 'with proc preprocessing' do
      let(:options) { {output: 'tmp', pre_process: Proc.new { |file| file.gsub(/raw coffee beans/, 'grinded coffee') }} }
      it do
        file = File.read("#{@project_path}/tmp/script_with_pre_processing.js")
        expect(file).to match(/alert\('grinded coffee'\);/)
      end
    end
  end

end