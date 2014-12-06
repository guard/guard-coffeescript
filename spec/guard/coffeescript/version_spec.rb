RSpec.describe Guard::CoffeeScriptVersion do
  describe 'VERSION' do
    it 'defines the version' do
      expect(Guard::CoffeeScriptVersion::VERSION).to match(/\d+\.\d+\.\d+/)
    end
  end
end
