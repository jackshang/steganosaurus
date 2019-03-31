require 'jpeg'

RSpec.describe Jpeg do
  context 'When creating a new Jpeg object with baseline data' do
    before do
      # With this test data:
      # SOS at pos = 8
      # image data = 590b44f5671d0d0a41e02802c04d7fff
      # NOTE: this is baseline jpeg, see wiki linked in readme
      @hex_image_data = ['ffd8ffe0ffda590b44f5671d0d0a41e02802c04d7fffffd9'].pack('H*')
      file_double = double('file')
      allow(File).to receive(:open).with('monkey.bmp', 'rb').and_return(file_double)
      allow(file_double).to receive(:size).and_return(@hex_image_data.size)
      allow(file_double).to receive(:read).with(@hex_image_data.size).and_return(@hex_image_data)
      @test_image = Jpeg.new('monkey.bmp')
    end

    it 'Should populate class variables' do
      # File Headers
      expect(@test_image.image_headers).to eq('ffd8ffe0')
      # expect(image.hex_pixel_data).to eq('590b44f5671d0d0a41e02802c04d7fff')
    end

    it 'Should populate image_headers when populate_image_header called' do
      image_header = 'ffd8HELLOTHERE!'
      @test_image.populate_image_header(image_header + Jpeg::SOS_HEX_MARKER)
      expect(@test_image.image_headers).to eq(image_header)
    end

    it 'Should populate single scan when populate_scans' do
      @test_image.populate_scans(@hex_image_data)
      expect(@test_image.pixel_data_scan_breaks.length).to eq(1)
      expect(@test_image.pixel_data_scan_breaks[0]).to eq(32)
    end

    it 'Should update data when encode_message is called' do
      allow(Transform).to receive(:encode_message).with(
        'a message'.unpack('B*')[0], anything, 8
      ).and_return('1111111100000000')

      @test_image.encode_message('a message')
      expect(@test_image.pixel_data).to eq('1111111100000000')
    end
  end

  context 'When creating a new Jpeg object with progressive data' do
    before do
      # With this test data:
      # SOS at pos = 8,24,36
      # image data[0] = 590b44f5671d
      # image data[1] = 0d0a41e0
      # image data[2] = 2802c04d7fff
      # NOTE: this is progressive jpeg, see wiki linked in readme
      @hex_image_data = ['ffd8ffe0ffda590b44f5671dffda0d0a41e0ffda2802c04d7fffffd9'].pack('H*')
      file_double = double('file')
      allow(File).to receive(:open).with('monkey.bmp', 'rb').and_return(file_double)
      allow(file_double).to receive(:size).and_return(@hex_image_data.size)
      allow(file_double).to receive(:read).with(@hex_image_data.size).and_return(@hex_image_data)
      @test_image = Jpeg.new('monkey.bmp')
    end

    it 'Should populate multiple scans when populate_scans' do
      @test_image.populate_scans(@hex_image_data)
      expect(@test_image.pixel_data_scan_breaks.length).to eq(3)
      expect(@test_image.pixel_data_scan_breaks[0]).to eq(12)
      expect(@test_image.pixel_data_scan_breaks[1]).to eq(8)
      expect(@test_image.pixel_data_scan_breaks[2]).to eq(12)
    end
  end
end
