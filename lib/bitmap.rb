# define file header structure
FileHeader = Struct.new(
  :bfType,
  :bfSize,
  :bfReserved1,
  :bfReserved2,
  :bfOffbits
)

# define image header structure
ImageHeader = Struct.new(
  :biSize,
  :biWidth,
  :biHeight,
  :biPlanes,
  :biBitCount,
  :biCompression,
  :biSizeImage,
  :biXPelsPerMeter,
  :biYPelsPerMeter,
  :biClrUsed,
  :biClrImportant
)

# Class to handle a bitmap file, currently only supports Windows
# Bitmap Header (BM)
class Bitmap
  attr_reader :file_header
  attr_reader :image_header

  def initialize(filename)
    load_file(filename)
  end

  def load_file(filename)
    puts 'Creating new Bitmap class'
    file = File.open(filename, 'rb')
    puts "File size: #{file.size}"
    raise 'File size is too small' if file.size < 54

    # Populate file_header
    binary = file.read(14)
    @file_header = binary.unpack('A2 L S S L')
    # Populate image header
    binary = file.read(40)
    @image_header = binary.unpack('L L L S S L L L L L L')
  end
end
