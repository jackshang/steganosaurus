# Class to transform pixel data
class Transform
  # Will be hiding message by converting to ascii
  # and then splitting into blocks of 2 bits
  # each block of to bits will be put as last 2 bits of
  # a byte of pixel data
  def self.image_big_enough?(message, pixel_data, bits_per_pixel)
    number_of_required_pixels = message.size / 2
    number_of_pixels = pixel_data.size / bits_per_pixel
    number_of_pixels > number_of_required_pixels
  end

  # Encodes the message into the pixel data
  # Message is expected to be unpacked
  # message.unpack('B*')[0]
  def self.encode_message(message, pixel_data, bits_per_pixel)
    raise 'Image not big enough to transform' unless image_big_enough?(
      message, pixel_data, bits_per_pixel
    )

    transformed_pixel_data = ''
    message_items = message.scan(/.{2}/)
    pixels = pixel_data.scan(/.{#{bits_per_pixel}}/)
    message_items.size.times do |i|
      transformed_pixel = pixels[i].gsub(/\d{2}$/, message_items[i])
      transformed_pixel_data.concat(transformed_pixel)
    end
    # Now fill in the rest of the original pxel data
    offset = 8 * (message.size / 2)
    transformed_pixel_data.concat(pixel_data[offset..-1])
  end

  # Goes through the pixel data and rebuilds original
  # message
  def self.decode_message(pixel_data, bits_per_pixel)
    decoded_message = ''
    pixel_data.scan(/.{#{bits_per_pixel}}/).each do |pixel|
      last_two_bits = pixel.reverse[0, 2].reverse
      decoded_message.concat(last_two_bits)
    end
    [decoded_message].pack('B*')
  end
end
