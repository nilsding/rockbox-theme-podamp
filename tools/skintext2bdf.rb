#!/usr/bin/env ruby
# convert a text.bmp over to a .bdf file for feeding it to rockbox's convbdf
#
# usage:
#    ./skintext2bdf.rb text.bmp > 06-WinAmp2.bdf
#    .../rockbox/tools/convbdf -f 06-WinAmp2.bdf
#
# known limitations:
#   - the '@' symbol is wider and therefore skipped for now
#   - it only works with text.bmp having a black background
#   - the '&' symbol is weirdly cutoff

require 'rmagick'

CHAR_WIDTH = 5
CHAR_HEIGHT = 6

BACKGROUND = Magick::Pixel.new(0, 0, 0, 65535) # background colour.  everything else in the image will be filled 

# Rows: rows in text.txt
# Columns: what characters this letter is mapped to
TEXT_CHARS = [
  [['A', 'a'], ['B', 'b'], ['C', 'c'], ['D', 'd'], ['E', 'e'], ['F', 'f'], ['G', 'g'], ['H', 'h'], ['I', 'i'], ['J', 'j'], ['K', 'k'], ['L', 'l'], ['M', 'm'], ['N', 'n'], ['O', 'o'], ['P', 'p'], ['Q', 'q'], ['R', 'r'], ['S', 's'], ['T', 't'], ['U', 'u'], ['V', 'v'], ['W', 'w'], ['X', 'x'], ['Y', 'y'], ['Z', 'z'], ['"'], [], [], [' ']],
  [['0'], ['1'], ['2'], ['3'], ['4'], ['5'], ['6'], ['7'], ['8'], ['9'], ['…'], ['.'], [':'], ['(', '<'], [')', '>'], ['-'], ["'"], ['!'], ['_'], ['+'], ['\\'], ['/'], ['[', '{'], [']', '}'], ['^'], ['&'], ['%'], [','], ['='], ['$'], ['#']],
  [['Å', 'å'], ['Ö', 'ö'], ['Ä', 'ä'], ['?'], ['*']]
]

bitmap_file = ARGV.shift
abort "usage: #$0 TEXT.BMP" unless bitmap_file

bitmap = Magick::Image.read(bitmap_file).first

# write BDF header
puts 'STARTFONT 2.1'
puts 'FONT WinAmp2'
puts "SIZE #{CHAR_HEIGHT} 75 75"

DESCENT = 1

puts "FONTBOUNDINGBOX #{CHAR_WIDTH} #{CHAR_HEIGHT} 0 -#{DESCENT}"
puts 'STARTPROPERTIES 4'
puts "FONT_ASCENT #{CHAR_HEIGHT}"
puts "FONT_DESCENT #{DESCENT}"
puts 'CHARSET_REGISTRY "ISO10646"'
puts 'CHARSET_ENCODING "1"'
puts "ENDPROPERTIES"
puts "CHARS #{TEXT_CHARS.flatten.size}"

TEXT_CHARS.each_with_index do |chars, row|
  chars.each_with_index do |char, column|
    # build bitmap for char
    char_bitmap = []
    xoff = CHAR_WIDTH * column
    yoff = CHAR_HEIGHT * row
    CHAR_HEIGHT.times do |crow|
      char_row = 0
      CHAR_WIDTH.times do |ccol|
        char_row |= 1 unless bitmap.pixel_color(xoff + ccol, yoff + crow) == BACKGROUND
        char_row <<= 1
      end
      char_row <<= 1
      char_bitmap << char_row
    end

    char.each do |c|
      puts 'STARTCHAR U+%04X' % c.ord
      puts 'ENCODING %d' % c.ord

      puts "SWIDTH #{CHAR_WIDTH * 1000} 0"
      puts "DWIDTH #{CHAR_WIDTH} 0"
      puts "BBX #{CHAR_WIDTH + 1} #{CHAR_HEIGHT} 0 -#{DESCENT}"

      puts 'BITMAP'
      char_bitmap.each do |crow|
        puts('%02X' % crow)
      end

      puts 'ENDCHAR'
    end
  end
end

puts 'ENDFONT'
