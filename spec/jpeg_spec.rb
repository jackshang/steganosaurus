require 'jpeg'

RSpec.describe Jpeg do
  context 'When creating a new Jpeg object' do
    before do
      # With this test data:
      # SOS at pos = 8
      # image data = 590b44f5671d0d0a41e02802c04d7fff
      hex_image_data = ['ffd8ffe0ffda590b44f5671d0d0a41e02802c04d7fffffda'].pack('H*')
      file_double = double('file')
      allow(File).to receive(:open).with('monkey.bmp', 'rb').and_return(file_double)
      allow(file_double).to receive(:size).and_return(hex_image_data.size)
      allow(file_double).to receive(:read).with(hex_image_data.size).and_return(hex_image_data)
    end

    it 'Should populate class variables' do
      image = Jpeg.new('monkey.bmp')
      # File Headers
      expect(image.sos_loc).to eq(8)
      expect(image.image_headers).to eq('ffd8ffe0')
      expect(image.hex_pixel_data).to eq('590b44f5671d0d0a41e02802c04d7fff')
    end

    it 'Should update data when encode_message is called' do
      allow(Transform).to receive(:encode_message).with(
        'a message'.unpack('B*')[0], anything, 8
      ).and_return('1111111100000000')
      image = Jpeg.new('monkey.bmp')
      image.encode_message('a message')
      expect(image.pixel_data).to eq('1111111100000000')
    end
  end
end
