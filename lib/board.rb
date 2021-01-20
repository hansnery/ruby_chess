# frozen_string_literal: true

# :nodoc:
# rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize
class Board
  require_relative 'tile'
  require 'colorize'

  attr_accessor :board, :target, :rows, :board_letters

  def initialize(size = 8, temp = [])
    @columns = []
    size.times do
      size.times do
        temp << Tile.new
      end
      @columns << temp
      temp = []
    end
    @rows = @columns.transpose
    setup_board
  end

  def print_board(pos = 8)
    puts "\n"
    @rows.each_with_index do |sub_array, idx|
      sub_array.each_with_index do |tile, index|
        tile_unselected_and_unhighlighted?(tile) ? print_black_and_white(sub_array, idx, index) : paint_tile(tile)
        puts "|#{pos}\n" if index == 7
        pos -= 1 if index == 7
      end
    end
    puts 'a b c d e f g h'
  end

  def tile_unselected_and_unhighlighted?(tile)
    tile.selected == false && tile.highlighted == false
  end

  def paint_tile(tile)
    to_selected_background(tile) if tile.selected == true
    to_highlighted_background(tile) if tile.highlighted == true
  end

  def print_black_and_white(sub_array, idx, index)
    print to_black_background(sub_array[index]) if idx.odd? && index.even?
    print to_white_background(sub_array[index]) if idx.odd? && index.odd? || idx.even? && index.even?
    print to_black_background(sub_array[index]) if idx.even? && index.odd?
  end

  def breakline?(index)
    breaklines = [7, 15, 23, 31, 39, 47, 55, 63]
    return true if breaklines.include?(index)
  end

  def white_tile?(index)
    white_tiles = [0, 2, 4, 6]
    return true if white_tiles.include?(index)
  end

  def to_white_background(string)
    string.data.colorize(background: :blue)
  end

  def to_black_background(string)
    string.data.colorize(background: :black)
  end

  def to_selected_background(string)
    print string.data.colorize(background: :red)
  end

  def to_highlighted_background(string)
    print string.data.colorize(background: :yellow)
  end

  def setup_board
    @board_letters = ('a'..'h').to_a
    create_board_coordinates
  end

  def create_board_coordinates
    j = 8
    @rows.each do |row|
      i = 0
      row.each do |el|
        el.longitude = @board_letters[i]
        el.latitude = j
        i += 1
      end
      j -= 1
    end
  end
end
# rubocop:enable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize
# EOF
