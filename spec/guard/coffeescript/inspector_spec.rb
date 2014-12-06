RSpec.describe Guard::CoffeeScript::Inspector do
  let(:inspector) { Guard::CoffeeScript::Inspector }

  describe 'clean' do
    it 'removes duplicate files' do
      expect(File).to receive(:exist?).with('a.coffee').and_return true
      expect(File).to receive(:exist?).with('b.coffee.md').and_return true
      expect(File).to receive(:exist?).with('c.litcoffee').and_return true
      expect(inspector.clean(['a.coffee', 'a.coffee', 'b.coffee.md', 'b.coffee.md', 'c.litcoffee', 'c.litcoffee']))
        .to eq(['a.coffee', 'b.coffee.md', 'c.litcoffee'])
    end

    it 'remove nil files' do
      expect(File).to receive(:exist?).with('a.coffee').and_return true
      expect(File).to receive(:exist?).with('b.coffee.md').and_return true
      expect(File).to receive(:exist?).with('c.litcoffee').and_return true
      expect(inspector.clean(['a.coffee', 'b.coffee.md', 'c.litcoffee', nil]))
        .to eq(['a.coffee', 'b.coffee.md', 'c.litcoffee'])
    end

    describe 'without the :missing_ok option' do
      it 'removes non-coffee files that do not exist' do
        expect(File).to receive(:exist?).with('a.coffee').and_return true
        expect(File).to receive(:exist?).with('c.litcoffee').and_return true
        expect(File).to receive(:exist?).with('d.coffee.md').and_return true
        expect(File).to receive(:exist?).with('doesntexist.coffee').and_return false
        expect(inspector.clean(['a.coffee', 'b.txt', 'doesntexist.coffee', 'c.litcoffee', 'd.coffee.md']))
          .to eq(['a.coffee', 'c.litcoffee', 'd.coffee.md'])
      end
    end

    describe 'with the :missing_ok options' do
      it 'removes non-coffee files' do
        expect(inspector.clean(['a.coffee', 'b.txt', 'doesntexist.coffee', 'c.litcoffee', 'd.coffee.md'],  missing_ok: true))
          .to eq(['a.coffee', 'doesntexist.coffee', 'c.litcoffee', 'd.coffee.md'])
      end
    end
  end
end
