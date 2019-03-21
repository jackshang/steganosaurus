require 'transform'

RSpec.describe Transform do
  context 'When image is not big enough to hide message in' do
    before do
      @pixel_data = [10].pack('C*').unpack('B*')[0]
      @message = 'A'.unpack('B*')[0]
    end

    it 'Should return false when image is not big enough' do
      expect(Transform.image_big_enough?(@message, @pixel_data)).to eq false
    end

    it 'Should throw an error when transorming the image' do
      expect { Transform.transform_image(@message, @pixel_data) }.to raise_error(
        'Image not big enough to transform'
      )
    end
  end

  context 'When image is big enough to hide message in' do
    before do
      @pixel_data = [10, 20, 30, 40, 10, 20, 30, 40].pack('C*').unpack('B*')[0]
      @message = 'A'.unpack('B*')[0]
    end

    it 'Should return true when image is big enough' do
      expect(Transform.image_big_enough?(@message, @pixel_data)).to eq true
    end

    it 'Should transform the image' do
      # message to transform is A = 01000001
      # Image is 8 bytes:
      # 00001010
      # 00010100
      # 00011110
      # 00101000
      # 00001010
      # 00010100
      # 00011110
      # 00101000
      # So replacing last to bits of each image byte is:
      transformed_pixel_data = Transform.transform_image(@message, @pixel_data)
      # puts transformed_pixel_data
      data_as_bytes = transformed_pixel_data.scan(/.{8}/)
      # Modified blocks
      expect(data_as_bytes[0]).to eq('00001001')
      expect(data_as_bytes[1]).to eq('00010100')
      expect(data_as_bytes[2]).to eq('00011100')
      expect(data_as_bytes[3]).to eq('00101001')
      # Unmodified blocks
      expect(data_as_bytes[4]).to eq('00001010')
      expect(data_as_bytes[5]).to eq('00010100')
      expect(data_as_bytes[6]).to eq('00011110')
      expect(data_as_bytes[7]).to eq('00101000')
    end
  end
end
