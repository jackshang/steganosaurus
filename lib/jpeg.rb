require_relative 'transform'

# Class to handle a jpeg file
# Based on this: https://en.wikipedia.org/wiki/JPEG_File_Interchange_Format
# We basically want to find the beginging of the compressed data, and then
# read until we get to the end marker. Then manipulate the shit in between!
# Note that I used the CLI hexdump to inspect local files: hexdump -C 10x10.jpg
class Jpeg
  SOS_HEX_MARKER = 'ffda'.freeze
  EOI_HEX_MARKER = 'ffd9'.freeze
  attr_reader :sos_loc, :hex_pixel_data, :pixel_data, :image_headers

  def initialize(filename)
    @filename = filename
    load_file(filename)
  end

  def load_file(filename)
    # puts 'Creating new Jpeg class'
    file = File.open(filename, 'rb')
    # Get image data between Start of Scan (ffda) and End of Image (ffd9) markers
    binary = file.read(file.size)
    data = binary.unpack('H*')[0]
    @sos_loc = data.index(SOS_HEX_MARKER)
    # End of Image is 4 bytes from end of data
    eoi = data.size - 4
    @image_headers = data[0..@sos_loc - 1]
    puts "Image Headers: #{@image_headers}"
    # actually want 4 bytes after SOS as beginging of data
    @hex_pixel_data = data[@sos_loc + 4...eoi]
    @pixel_data = [@hex_pixel_data].pack('H*').unpack('B*')[0]
  end

  def encode_message(message)
    # puts 'In encode_message'
    @pixel_data = Transform.encode_message(
      message.unpack('B*')[0], @pixel_data, 8
    )
  end

  def save_image
    new_file = File.open('modified-'.concat(@filename), 'wb')
    # Write original file up to pixel data
    new_file.write([@image_headers].pack('H*'))
    new_file.write([SOS_HEX_MARKER].pack('H*'))
    new_file.write([@pixel_data].pack('B*'))
    new_file.write([EOI_HEX_MARKER].pack('H*'))
    new_file.close
  end
end
