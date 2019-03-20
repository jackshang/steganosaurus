# Factory class
class Image
  def self.open(filename)
    case File.extname(filename)
    when '.bmp'
      Bitmap.new(filename)
    else
      raise 'Unsupported file type'
    end
  end
end
