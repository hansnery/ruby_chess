# frozen_string_literal: true

# :nodoc:
class Chess
  Dir[File.dirname(__FILE__) + '/lib/*.rb'].sort.each { |file| require file }
  require 'colorize'
  include BoardMethods

  def initialize
    @turn = 'white'
    @moving = false
    welcome
    @board = Board.new
    setup_pieces
    ask_input
  end

  def welcome
    puts "\nWelcome to RubyChess!\n\nIn this program you can play chess using just the command line!"
    puts "\nTo select and move a piece, type in the piece\'s"
    puts 'coordinates using algebraic notation (eg: b3).'
  end

  def ask_input
    @board.print_board
    if @moving == false
      print_select_piece
    else
      print_move_to
    end
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
      try_again('wrong_input')
    end
  end

  def play_round(input)
    if @moving == false
      check_tile_and_piece
      select_piece
      show_possible_moves
      select_destination
    else
      check_move(input)
      ask_input
    end
  end

  def try_again(because)
    puts 'Wrong input! Try again!' if because == 'wrong_input'
    puts 'It\'s white\'s turn!' if because == 'whites_turn'
    puts 'It\'s black\'s turn!' if because == 'blacks_turn'
    ask_input
  end

  def check_tile_and_piece
    target_tile = find_tile(@target_longitude, @target_latitude)
    target_piece = find_piece(@target_longitude, @target_latitude)
    try_again('wrong_input') if target_tile.empty? && @moving == false
    return unless target_piece.respond_to?(:side)

    try_again('blacks_turn') if target_piece.side == 'white' && @turn != 'white' && @moving == false
    try_again('whites_turn') if target_piece.side == 'black' && @turn != 'black' && @moving == false
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
      if tile.respond_to?(:longitude) && tile.respond_to?(:latitude)
        tile.highlighted = true
        @highlighted_tiles << tile
      else
        try_again('wrong_input')
      end
    end
  end

  def check_destination(input)
    try_again('wrong_input') if input == number_to_letter(@selected_piece.longitude) + @selected_piece.latitude.to_s
    check_tile_and_piece
    piece = find_piece(@target_longitude, @target_latitude)
    # p piece
    return if piece.nil?

    piece.longitude = nil
    piece.latitude = nil
    # p piece
  end

  def select_destination
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
      @turn = 'black' if @selected_piece.side == 'white'
      @turn = 'white' if @selected_piece.side == 'black'
    end
  end

  def print_select_piece
    if @turn == 'white'
      puts 'SELECT PIECE(WHITE): '
    else
      puts 'SELECT PIECE(BLACK): '
    end
  end

  def print_move_to
    if @turn == 'white'
      puts 'MOVE TO(WHITE): '
    else
      puts 'MOVE TO(BLACK): '
    end
  end
end

Chess.new
