require_relative 'transform'

# Class to handle a jpeg file
# Based on this: https://en.wikipedia.org/wiki/JPEG_File_Interchange_Format
# We basically want to find the beginging of the compressed data, and then
# read until we get to the end marker. Then manipulate the shit in between!
# Note that I used the CLI hexdump to inspect local files: hexdump -C 10x10.jpg
class Jpeg
  SOS_HEX_MARKER = 'ffda'.freeze
  EOI_HEX_MARKER = 'ffd9'.freeze
  attr_reader :hex_pixel_data, :pixel_data, :image_headers, :pixel_data_scan_breaks

  def initialize(filename)
    @filename = filename
    @pixel_data_scan_breaks = []
    @hex_pixel_data = ''
    load_file(filename)
  end

  def load_file(filename)
    # puts 'Creating new Jpeg class'
    file = File.open(filename, 'rb')
    # Get image data between Start of Scan (ffda) and End of Image (ffd9) markers
    binary = file.read(file.size)
    data = binary.unpack('H*')[0]
    # populate image header
    populate_image_header(data)
    # populate scans
    populate_scans(data)
    # End of Image is 4 bytes from end of data
    # eoi = data.size - 4
    # # actually want 4 bytes after SOS as beginging of data
    # @hex_pixel_data = data[@sos_loc + 4...eoi]
    # @pixel_data = [@hex_pixel_data].pack('H*').unpack('B*')[0]
  end

  def populate_image_header(data)
    sos_loc = data.index(SOS_HEX_MARKER)
    @image_headers = data[0..sos_loc - 1]
  end

  def populate_scans(data)
    # jpeg can be baseline or progressive: https://en.wikipedia.org/wiki/JPEG
    # so potentially can have multiple scans, find all and put into array
    # scan starts with SOS_HEX_MARKER
    sos_loc = 0
    until sos_loc.nil?
      next_sos_loc = data.index(SOS_HEX_MARKER, sos_loc + 1)
      if sos_loc > 0
        scan_data = ''
        scan_data += if next_sos_loc.nil?
                       data[(sos_loc + 4)...(data.size - 4)]
                     else
                       data[(sos_loc + 4)...next_sos_loc]
                     end
        @hex_pixel_data += scan_data
        @pixel_data_scan_breaks.push(scan_data.length)
      end
      sos_loc = next_sos_loc
    end
  end

  def encode_message(message)
    # puts 'In encode_message'
    @pixel_data = [@hex_pixel_data].pack('H*').unpack('B*')[0]
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
