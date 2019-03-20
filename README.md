# Image Steganography
This is a small application written as a steganography exercise.
Nothing fancy, just a bit of fun.

# Refernce Links
Useful references used when working on this project

* [Ruby Pack/Unpack](https://www.rubydoc.info/stdlib/core/String:unpack)
* [BMP File Format](https://en.wikipedia.org/wiki/BMP_file_format)
* [Working with Binary Files Example](https://www.visuality.pl/posts/cs-lessons-001-working-with-binary-files)
* [rspec expect vs expect block](https://stackoverflow.com/questions/19960831/rspec-expect-vs-expect-with-block-whats-the-difference) Hadn't come across this before strangely!

# Setup / Run
```
bundle install
bundle exec rake
```

```
ruby stegography.rb monkey.bmp d
ruby stegography.rb monkey.bmp e "This is a secret message"
```
