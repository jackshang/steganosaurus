require 'rubygems'
require './lib/image'

input_array = ARGV

if input_array.length < 2
  puts 'Missing input: <filename> <E(ncode)|D(ecode)> <Message>'
  exit
end

image_filename = input_array[0]
puts "Image file name: #{image_filename}"
encode_decode = input_array[1]
case encode_decode
when 'e', 'E'
  puts 'Encoding message...'
  image = Image.open(image_filename)
  image.encode_message(input_array[2])
  image.save_image
when 'd', 'D'
  puts 'Decoding Message...'
  image = Image.open(image_filename)
  puts image.decode_message
else
  puts 'Unrecognised encode/decode flag, exiting...'
  exit
end
