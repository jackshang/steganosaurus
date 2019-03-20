require 'bitmap'

RSpec.describe Bitmap do
  context 'When creating a new Bitmap object with small file' do
    before do
      fake_headers = ['BM', 263_222, 0, 0, 1078].pack('A2 L L S L')
      allow(File).to receive(:open).with('small.bmp', 'rb').and_return(fake_headers)
    end

    it 'Should thow exception when file size too small' do
      expect { Bitmap.new('small.bmp') }.to raise_error('File size is too small')
    end
  end

  context 'When creating a new Bitmap object' do
    before do
      file_header = ['BM', 263_222, 0, 0, 1078].pack('A2 L S S L')
      image_header = [40, 512, 512, 1, 8, 0, 262_144, 0, 0, 256, 0].pack('L L L S S L L L L L L')
      file_double = double('file')
      allow(File).to receive(:open).with('monkey.bmp', 'rb').and_return(file_double)
      allow(file_double).to receive(:size).and_return(54)
      allow(file_double).to receive(:read).with(14).and_return(file_header)
      allow(file_double).to receive(:read).with(40).and_return(image_header)
    end

    it 'Should populate the file parts' do
      image =  Bitmap.new('monkey.bmp')
      expect(image.file_header).to eq(['BM', 263_222, 0, 0, 1078])
      expect(image.image_header).to eq([40, 512, 512, 1, 8, 0, 262_144, 0, 0, 256, 0])
    end
  end
end
