require 'spec_helper'

describe Guard::CoffeeScript::Inspector do
  before do
    File.should_receive(:exists?).with("a.coffee").and_return true
  end

  let(:inspector) { Guard::CoffeeScript::Inspector }

  describe 'clean' do
    it 'removes duplicate files' do
      inspector.clean(['a.coffee', 'a.coffee']).should == ['a.coffee']
    end

    it 'remove nil files' do
      inspector.clean(['a.coffee', nil]).should == ['a.coffee']
    end

    it 'removes non-coffee files' do
      File.should_receive(:exists?).with("doesntexist.coffee").and_return false
      inspector.clean(['a.coffee', 'b.txt', 'doesntexist.coffee']).should == ['a.coffee']
    end

  end
end
