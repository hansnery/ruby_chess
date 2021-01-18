# frozen_string_literal: true

# :nodoc:
class KnightsTravail
  require_relative 'lib/board'
  require_relative 'lib/knight'
  require_relative 'lib/board_methods'
  include BoardMethods

  def initialize(initial_longitude = 1, initial_latitude = 1)
    welcome
    @board = Board.new
    @knight = Knight.new(initial_longitude, initial_latitude)
    position_piece(@knight)
    @board.print_board
    ask_input
  end

  def welcome
    puts "\nWelcome to the Knight's Travail!\n\nIn this program you can calculate the shortest "
    puts 'amount of moves necessary to move the knight to a certain position on the board.'
    puts "\nType in the knight's destination using algebraic notation (eg: b3)."
  end

  def ask_input
    puts 'MOVE TO: '
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

  def search_route
    until @queue.empty?
      current_tile = @queue.first
      update_position(letter_to_number(current_tile.longitude), current_tile.latitude)
      @piece.possible_moves.each do |move|
        break if @target.visited == true

        new_longitude = @piece.longitude + move[0]
        new_latitude = @piece.latitude + move[1]
        next_tile = find_tile(new_longitude, new_latitude)

        next unless valid_move?(new_longitude, new_latitude) && next_tile.visited == false

        next_tile.visited = true
        next_tile.parent = current_tile
        current_tile.children << next_tile

        @queue << next_tile
      end
      @queue.shift
    end
    knight_moves
  end

  def count_parents(tile)
    return if tile.parent.nil?

    move = []
    move << tile.parent.longitude
    move << tile.parent.latitude
    @result << move
    count_parents(tile.parent)
  end

  def knight_moves
    @result = []
    final_move = [@target.longitude, @target.latitude]
    @result << final_move
    count_parents(@target)
    @result.pop if @result.size > 1
    puts "Minimum moves to reach the target: #{@result.reverse}"
  end
end

KnightsTravail.new
