require 'rubygems'

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
when 'd', 'D'
  puts 'Decoding Message...'
else
  puts 'Unrecognised encode/decode flag, exiting...'
  exit
end
