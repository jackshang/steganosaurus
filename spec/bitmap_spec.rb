require 'bitmap'

RSpec.describe Bitmap do
  context 'When creating a new Bitmap object with small file' do
    before do
      fake_headers = ['BM', 263_222, 0, 0, 1078].pack('A2 L L S L')
      allow(File).to receive(:open).with('monkey.bmp', 'rb').and_return(fake_headers)
    end

    it 'Should thow exception when file size too small' do
      expect { Bitmap.new('monkey.bmp') }.to raise_error('File size is too small')
    end
  end

  context 'When creating a new Bitmap object' do
    before do
      fake_headers = ['BM', 263_222, 0, 0, 1078].pack('A2 L L S L')
      allow(File).to receive(:open).with('monkey.bmp', 'rb').and_return(fake_headers)
    end
  end
end
