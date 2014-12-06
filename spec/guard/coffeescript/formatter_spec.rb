RSpec.describe Guard::CoffeeScript::Formatter do
  let(:formatter) { Guard::CoffeeScript::Formatter }
  let(:ui) { Guard::UI }
  let(:notifier) { Guard::Notifier }

  describe '.info' do
    it 'shows an info message' do
      expect(ui).to receive(:info).with('Info message',  reset: true)
      formatter.info('Info message',  reset: true)
    end
  end

  describe '.debug' do
    it 'shows a debug message' do
      expect(ui).to receive(:debug).with('Debug message',  reset: true)
      formatter.debug('Debug message',  reset: true)
    end
  end

  describe '.error' do
    it 'shows a colorized error message' do
      expect(ui).to receive(:error).with("\e[0;31mError message\e[0m",  reset: true)
      formatter.error('Error message',  reset: true)
    end
  end

  describe '.success' do
    it 'shows a colorized success message with a timestamp' do
      expected_success_message = %r{^\e\[0;32m\d{2}:\d{2}:\d{2} (AM|PM) Success message\e\[0m$}
      expect(ui).to receive(:info).with(expected_success_message,  reset: true)
      formatter.success('Success message',  reset: true)
    end
  end

  describe '.notify' do
    it 'shows an info message' do
      expect(notifier).to receive(:notify).with('Notify message',  image: :failed)
      formatter.notify('Notify message',  image: :failed)
    end
  end
end
