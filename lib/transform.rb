# Class to transform pixel data
class Transform
  # Will be hiding message by converting to ascii
  # and then splitting into blocks of 2 bits
  # each block of to bits will be put as last 2 bits of
  # a byte of pixel data
  def self.image_big_enough?(message, pixel_data)
    number_of_required_pixels = message.size / 2
    number_of_pixels = pixel_data.size / 8
    number_of_pixels > number_of_required_pixels
  end

  # Transforms the pixel data with the message
  # Message is expected to be unpacked
  # message.unpack('B*')[0]
  def self.transform_image(message, pixel_data)
    raise 'Image not big enough to transform' unless image_big_enough?(message, pixel_data)

    transformed_pixel_data = ''
    message_items = message.scan(/.{2}/)
    pixels = pixel_data.scan(/.{8}/)
    message_items.size.times do |i|
      transformed_pixel = pixels[i].gsub(/\d{2}$/, message_items[i])
      transformed_pixel_data.concat(transformed_pixel)
    end
    # Now fill in the rest of the original pxel data
    offset = 8 * (message.size / 2)
    transformed_pixel_data.concat(pixel_data[offset..-1])
  end
end
