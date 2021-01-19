# frozen_string_literal: true

# :nodoc:
class Chess
  Dir[File.dirname(__FILE__) + '/lib/*.rb'].sort.each { |file| require file }
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
        @black_rook1 = Rook.new(1, 8, 'black'), @black_rook2 = Rook.new(7, 8, 'black'),
        @black_knight1 = Knight.new(2, 8, 'black'), @black_knight2 = Knight.new(8, 8, 'black'),
        @black_bishop1 = Bishop.new(3, 8, 'black'), @black_bishop2 = Bishop.new(6, 8, 'black'),
        @black_queen = Queen.new(4, 8, 'black'), @black_king = King.new(5, 8, 'black')
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
        @white_rook1 = Rook.new(1, 1, 'white'), @white_rook2 = Rook.new(7, 1, 'white'),
        @white_knight1 = Knight.new(2, 1, 'white'), @white_knight2 = Knight.new(8, 1, 'white'),
        @white_bishop1 = Bishop.new(3, 1, 'white'), @white_bishop2 = Bishop.new(6, 1, 'white'),
        @white_queen = Queen.new(4, 1, 'white'), @white_king = King.new(5, 1, 'white')
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
      set_target(@target_longitude, @target_latitude)
      @queue = []
      @queue << find_tile(@piece.longitude, @piece.latitude)
      search_route
    else
      puts 'Wrong input! Try again!'
      ask_input
    end
  end

  # def search_route
  #   until @queue.empty?
  #     current_tile = @queue.first
  #     update_position(letter_to_number(current_tile.longitude), current_tile.latitude)
  #     @piece.possible_moves.each do |move|
  #       break if @target.visited == true

  #       new_longitude = @piece.longitude + move[0]
  #       new_latitude = @piece.latitude + move[1]
  #       next_tile = find_tile(new_longitude, new_latitude)

  #       next unless valid_move?(new_longitude, new_latitude) && next_tile.visited == false

  #       next_tile.visited = true
  #       next_tile.parent = current_tile
  #       current_tile.children << next_tile

  #       @queue << next_tile
  #     end
  #     @queue.shift
  #   end
  #   knight_moves
  # end

  # def count_parents(tile)
  #   return if tile.parent.nil?

  #   move = []
  #   move << tile.parent.longitude
  #   move << tile.parent.latitude
  #   @result << move
  #   count_parents(tile.parent)
  # end

  # def knight_moves
  #   @result = []
  #   final_move = [@target.longitude, @target.latitude]
  #   @result << final_move
  #   count_parents(@target)
  #   @result.pop if @result.size > 1
  #   puts "Minimum moves to reach the target: #{@result.reverse}"
  # end
end

Chess.new
