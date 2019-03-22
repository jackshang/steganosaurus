require_relative 'transform'

# Class to handle a bitmap file, currently only supports Windows
# Bitmap Header (BM)
#
# Heavily based on:
# https://www.visuality.pl/posts/cs-lessons-001-working-with-binary-files
# https://en.wikipedia.org/wiki/BMP_file_format
class Bitmap
  # define file header structure
  FileHeader = Struct.new(
    :type,
    :size,
    :reserved1,
    :reserved2,
    :offbits
  )

  # define image header structure
  ImageHeader = Struct.new(
    :size,
    :width,
    :height,
    :planes,
    :bit_count,
    :compression,
    :size_image,
    :x_pels_per_meter,
    :y_pels_per_meter,
    :clr_used,
    :clr_important
  )
  attr_reader :file_header, :image_header, :pixel_data

  def initialize(filename)
    @filename = filename
    load_file(filename)
  end

  def load_file(filename)
    # puts 'Creating new Bitmap class'
    file = File.open(filename, 'rb')
    # puts "File size: #{file.size}"
    raise 'File size is too small' if file.size < 54

    populate_file_header(file)
    populate_image_header(file)

    # Ignore colour table, and jump straight to pixel data
    file.seek(@file_header.offbits)
    binary = file.read(@image_header.size_image)
    @pixel_data = binary.unpack('B*')[0]
  end

  def populate_file_header(file)
    # Populate file_header
    binary = file.read(14)
    data = binary.unpack('A2 L S S L')
    @file_header = FileHeader.new(*data)
    raise 'Unsupported Image Header' unless file_header.type.eql? 'BM'
  end

  def populate_image_header(file)
    # Populate image header of BM type
    binary = file.read(40)
    data = binary.unpack('L L L S S L L L L L L')
    @image_header = ImageHeader.new(*data)
  end

  def transform_image(message)
    @pixel_data = Transform.transform_image(message, @pixel_data)
  end

  def save_image
    orig_file = File.open(@filename, 'rb')
    new_file = File.open('modified-'.concat(@filename), 'wb')
    new_file.write(orig_file.read(@file_header.offbits))
    new_file.write(orig_file.read(@image_header.size_image))
    new_file.close
  end
end
