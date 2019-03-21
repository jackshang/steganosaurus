require 'bitmap'

RSpec.describe Bitmap do
  context 'When creating a new Bitmap object with small file' do
    it 'Should thow exception when file size too small' do
      file_double = double('file')
      allow(File).to receive(:open).with('small.bmp', 'rb').and_return(file_double)
      allow(file_double).to receive(:size).and_return(14)
      expect { Bitmap.new('small.bmp') }.to raise_error('File size is too small')
    end
  end

  context 'When creating a new Bitmap object with unsupported Image Header Type' do
    it 'Should thow exception when file size too small' do
      file_header = ['CI', 263_222, 0, 0, 1078].pack('A2 L S S L')
      file_double = double('file')
      allow(File).to receive(:open).with('incorrect.bmp', 'rb').and_return(file_double)
      allow(file_double).to receive(:size).and_return(54)
      allow(file_double).to receive(:read).with(14).and_return(file_header)
      expect { Bitmap.new('incorrect.bmp') }.to raise_error('Unsupported Image Header')
    end
  end

  context 'When creating a new Bitmap object' do
    before do
      file_header = ['BM', 263_222, 0, 1, 1078].pack('A2 L S S L')
      image_header = [40, 4, 5, 1, 8, 0, 20, 3, 7, 256, 6].pack('L L L S S L L L L L L')
      # rubocop:disable Metrics/LineLength
      pixel_data = [0, 0, 0, 0, 10, 10, 10, 10, 20, 20, 20, 20, 30, 30, 30, 30, 40, 40, 40, 40].pack('C*')
      # rubocop:enable Metrics/LineLength
      file_double = double('file')
      allow(File).to receive(:open).with('monkey.bmp', 'rb').and_return(file_double)
      allow(file_double).to receive(:size).and_return(54)
      allow(file_double).to receive(:read).with(14).and_return(file_header)
      allow(file_double).to receive(:read).with(40).and_return(image_header)
      allow(file_double).to receive(:seek).with(1078)
      allow(file_double).to receive(:read).with(20).and_return(pixel_data)
    end

    it 'Should populate the file parts' do
      image = Bitmap.new('monkey.bmp')
      # File Headers
      expect(image.file_header.type).to eq('BM')
      expect(image.file_header.size).to eq(263_222)
      expect(image.file_header.reserved1).to eq(0)
      expect(image.file_header.reserved2).to eq(1)
      expect(image.file_header.offbits).to eq(1078)
      # Image Headers (BM Only supported)
      expect(image.image_header.size).to eq(40)
      expect(image.image_header.width).to eq(4)
      expect(image.image_header.height).to eq(5)
      expect(image.image_header.planes).to eq(1)
      expect(image.image_header.bit_count).to eq(8)
      expect(image.image_header.compression).to eq(0)
      expect(image.image_header.size_image).to eq(20)
      expect(image.image_header.x_pels_per_meter).to eq(3)
      expect(image.image_header.y_pels_per_meter).to eq(7)
      expect(image.image_header.clr_used).to eq(256)
      expect(image.image_header.clr_important).to eq(6)
      # Pixel data
      # rubocop:disable Metrics/LineLength
      expect(image.pixel_data).to eq('0000000000000000000000000000000000001010000010100000101000001010000101000001010000010100000101000001111000011110000111100001111000101000001010000010100000101000')
      # rubocop:enable Metrics/LineLength
    end

    it 'Should update data when transform_image is called' do
      allow(Transform).to receive(:transform_image).with(
        'a message', anything
      ).and_return('1111111100000000')
      image = Bitmap.new('monkey.bmp')
      image.transform_image('a message')
      expect(image.pixel_data).to eq('1111111100000000')
    end
  end
end
