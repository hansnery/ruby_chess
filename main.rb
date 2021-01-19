# frozen_string_literal: true

# :nodoc:
class Chess
  Dir[File.dirname(__FILE__) + '/lib/*.rb'].sort.each { |file| require file }
  require 'colorize'
  include BoardMethods

  def initialize
    welcome
    @board = Board.new
    setup_pieces
    @board.print_board
    ask_input
  end

  def setup_pieces
    @pieces = []
    black_first_row.map { |piece| @pieces << piece }
    black_second_row.map { |piece| @pieces << piece }
    white_first_row.map { |piece| @pieces << piece }
    white_second_row.map { |piece| @pieces << piece }
    position_pieces(@pieces)
  end

  def black_first_row
    black_first_row =
      [
        @black_rook1 = Rook.new(1, 8, 'black'), @black_rook2 = Rook.new(8, 8, 'black'),
        @black_knight1 = Knight.new(2, 8, 'black'), @black_knight2 = Knight.new(7, 8, 'black'),
        @black_bishop1 = Bishop.new(3, 8, 'black'), @black_bishop2 = Bishop.new(6, 8, 'black'),
        @black_king = King.new(5, 8, 'black'), @black_queen = Queen.new(4, 8, 'black')
      ]
    black_first_row
  end

  def black_second_row
    black_second_row =
      [
        @black_pawn1 = Pawn.new(1, 7, 'black'), @black_pawn2 = Pawn.new(2, 7, 'black'),
        @black_pawn3 = Pawn.new(3, 7, 'black'), @black_pawn4 = Pawn.new(4, 7, 'black'),
        @black_pawn5 = Pawn.new(5, 7, 'black'), @black_pawn6 = Pawn.new(6, 7, 'black'),
        @black_pawn7 = Pawn.new(7, 7, 'black'), @black_pawn8 = Pawn.new(8, 7, 'black')
      ]
    black_second_row
  end

  def white_first_row
    white_first_row =
      [
        @white_rook1 = Rook.new(1, 1, 'white'), @white_rook2 = Rook.new(8, 1, 'white'),
        @white_knight1 = Knight.new(2, 1, 'white'), @white_knight2 = Knight.new(7, 1, 'white'),
        @white_bishop1 = Bishop.new(3, 1, 'white'), @white_bishop2 = Bishop.new(6, 1, 'white'),
        @white_king = King.new(5, 1, 'white'), @white_queen = Queen.new(4, 1, 'white')
      ]
    white_first_row
  end

  def white_second_row
    white_second_row =
      [
        @white_pawn1 = Pawn.new(1, 2, 'white'), @white_pawn2 = Pawn.new(2, 2, 'white'),
        @white_pawn3 = Pawn.new(3, 2, 'white'), @white_pawn4 = Pawn.new(4, 2, 'white'),
        @white_pawn5 = Pawn.new(5, 2, 'white'), @white_pawn6 = Pawn.new(6, 2, 'white'),
        @white_pawn7 = Pawn.new(7, 2, 'white'), @white_pawn8 = Pawn.new(8, 2, 'white')
      ]
    white_second_row
  end

  def welcome
    puts "\nWelcome to RubyChess!\n\nIn this program you can play chess using just the command line!"
    puts "\nTo select the piece you wish to move, type in the piece\'s"
    puts 'coordinates using algebraic notation (eg: b3).'
  end

  def ask_input
    puts 'SELECT PIECE: '
    input = gets.chomp
    @target_longitude = letter_to_longitude(input[0])
    @target_latitude = input[1].to_i
    check_input(input)
  end

  def check_input(input)
    case input
    when /^[a-hA-H]{1}[1-8]/
      @selected_piece = find_piece(@target_longitude, @target_latitude)
      tile = find_tile(@target_longitude, @target_latitude)
      tile.selected = true
      @board.print_board
    else
      puts 'Wrong input! Try again!'
      ask_input
    end
  end

  def find_piece(longitude, latitude)
    @pieces.map do |piece|
      return piece if piece.longitude == longitude && piece.latitude == latitude
    end
  end

  # def show_possible_moves

  # end
end

Chess.new
