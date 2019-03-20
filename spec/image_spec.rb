require 'image'

RSpec.describe Image do
  context 'When requesting a new image Object' do
    it 'Should throw an error when unsupported file type is requested' do
      expect { Image.open('test.ggp') }.to raise_error('Unsupported file type')
    end

    it 'Should return a Bitmap object when bitmap filename is used' do
      allow_any_instance_of(Bitmap).to receive(:load_file).with('test.bmp')
      expect(Image.open('test.bmp')).to be_instance_of(Bitmap)
    end
  end
end
