require_relative 'bitmap'
require_relative 'jpeg'

# Factory class
class Image
  def self.open(filename)
    case File.extname(filename)
    when '.bmp'
      Bitmap.new(filename)
    when '.jpg'
      Jpeg.new(filename)
    else
      raise 'Unsupported file type'
    end
  end
end
