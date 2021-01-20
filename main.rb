# frozen_string_literal: true

# :nodoc:
class Chess
  Dir[File.dirname(__FILE__) + '/lib/*.rb'].sort.each { |file| require file }
  require 'colorize'
  include BoardMethods

  def initialize
    @moving = false
    welcome
    @board = Board.new
    setup_pieces
    @board.print_board
    ask_input
  end

  def welcome
    puts "\nWelcome to RubyChess!\n\nIn this program you can play chess using just the command line!"
    puts "\nTo select the piece you wish to move, type in the piece\'s"
    puts 'coordinates using algebraic notation (eg: b3).'
  end

  def ask_input
    @moving == false ? 'SELECT PIECE: ' : 'MOVE TO: '
    input = gets.chomp
    @target_longitude = letter_to_longitude(input[0])
    @target_latitude = input[1].to_i
    check_input(input)
  end

  def check_input(input)
    case input
    when /^[a-hA-H]{1}[1-8]/
      play_round(input)
    else
      wrong_input
    end
  end

  def play_round(input)
    if @moving == false
      check_tile
      select_piece
      show_possible_moves
      select_destination
    else
      check_move(input)
      ask_input
    end
  end

  def wrong_input
    puts 'Wrong input! Try again!'
    ask_input
  end

  def check_tile
    target = find_tile(@target_longitude, @target_latitude)
    wrong_input if target.empty?
  end

  def check_destination(input)
    wrong_input if input == number_to_letter(@selected_piece.longitude) + @selected_piece.latitude.to_s
  end

  def select_piece
    @selected_piece = find_piece(@target_longitude, @target_latitude)
    @selected_tile = find_tile(@target_longitude, @target_latitude)
    @selected_tile.selected = true
  end

  def show_possible_moves
    @highlighted_tiles = []
    @selected_piece.possible_moves.shift if @selected_piece.class == Pawn && @selected_piece.jumped?
    @selected_piece.possible_moves.map do |move|
      tile = find_tile(@target_longitude + move[0], @target_latitude + move[1])
      tile.highlighted = true
      @highlighted_tiles << tile
    end
    @board.print_board
  end

  def select_destination
    puts "\nTo move the piece, type in the tile\'s"
    puts 'coordinates using algebraic notation (eg: b3).'
    @moving = true
    ask_input
  end

  def check_move(input)
    check_destination(input)
    @highlighted_tiles.map do |tile|
      longitude = tile.longitude.to_s
      latitude = tile.latitude.to_s
      move_piece(letter_to_longitude(longitude), latitude.to_i) if input == longitude + latitude
      clear_board
      @selected_piece.moved_once = true if @selected_piece.class == Pawn && @selected_piece.moved_once == false
      @moving = false
    end
  end
end

Chess.new
