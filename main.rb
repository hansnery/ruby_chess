# frozen_string_literal: true

# :nodoc:
# rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize
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
      move(input)
      ask_input
    end
  end

  def try_again(because)
    puts "\nWrong input! Try again!".colorize(color: :yellow) if because == 'wrong_input'
    puts "\nIt\'s white\'s turn!".colorize(color: :yellow) if because == 'whites_turn'
    puts "\nIt\'s black\'s turn!".colorize(color: :yellow) if because == 'blacks_turn'
    puts "\nThis piece can\'t move! Choose another one.".colorize(color: :yellow) if because == 'cant_move'
    puts "\nCan\'t move to the same place!".colorize(color: :yellow) if because == 'cant_move_to_same_place'
    ask_input
  end

  def check_tile_and_piece
    target_tile = find_tile(@target_longitude, @target_latitude)
    target_piece = find_piece(@target_longitude, @target_latitude)
    try_again('wrong_input') if target_tile.empty? && @moving == false
    try_again('wrong_input') if target_tile.highlighted == false && @moving == true
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
    pawn_moves if @selected_piece.instance_of?(Pawn)
    rook_moves if @selected_piece.instance_of?(Rook)
  end

  def pawn_moves
    check_for_pawn_diagonals if @selected_piece.instance_of?(Pawn)
    @selected_piece.possible_moves.shift if @selected_piece.instance_of?(Pawn) && @selected_piece.jumped?
    @selected_piece.possible_moves.map do |move|
      tile = find_tile(@target_longitude + move[0], @target_latitude + move[1])
      if inside_the_board?(tile) && (tile.empty? || tile.not_empty? && move[1] != 1 && move[1] != -1)
        tile.highlighted = true
        @highlighted_tiles << tile
      else
        next unless @highlighted_tiles.empty?

        clear_board
        try_again('cant_move')
      end
    end
  end

  def check_for_pawn_diagonals
    return unless @selected_piece.instance_of?(Pawn)

    @selected_piece.diagonal_attack.map do |move|
      piece = find_piece(@target_longitude + move[0], @target_latitude + move[1])
      tile = find_tile(@target_longitude + move[0], @target_latitude + move[1])
      next unless inside_the_board?(tile) && tile.not_empty? && piece.side != @selected_piece.side

      tile.highlighted = true
      @highlighted_tiles << tile
    end
  end

  def rook_moves
    @selected_piece.possible_moves.map do |direction|
      direction.map do |move|
        tile = find_tile(@target_longitude + move[0], @target_latitude + move[1])
        if inside_the_board?(tile) && tile.empty?
          tile.highlighted = true
          @highlighted_tiles << tile
        end
        next unless inside_the_board?(tile) && tile.not_empty?

        # puts "--Tile--\nData: #{tile.data}\nLongitude: #{tile.longitude}\nLatitude: #{tile.latitude}\n--------"
        tile.highlighted = true
        @highlighted_tiles << tile
        break
      end
    end
  end

  def inside_the_board?(tile)
    return true if tile.respond_to?(:longitude) && tile.respond_to?(:latitude)
  end

  def same_place?(input)
    input == number_to_letter(@selected_piece.longitude) + @selected_piece.latitude.to_s
  end

  def kill_piece
    piece = find_piece(@target_longitude, @target_latitude)
    # p piece
    return if piece.nil?

    piece.longitude = nil
    piece.latitude = nil
    # p piece
  end

  def check_move(input)
    try_again('cant_move_to_same_place') if same_place?(input)
    check_tile_and_piece
    kill_piece
  end

  def select_destination
    @moving = true
    ask_input
  end

  def move(input)
    @highlighted_tiles.map do |tile|
      longitude = tile.longitude.to_s
      latitude = tile.latitude.to_s
      # puts "\nYou picked a piece, now you must move it!".colorize(color: :yellow) unless input == longitude + latitude
      next unless input == longitude + latitude

      move_piece(letter_to_longitude(longitude), latitude.to_i) # if input == longitude + latitude
      clear_board
      @selected_piece.moved_once = true if @selected_piece.instance_of?(Pawn) && @selected_piece.moved_once == false
      @moving = false
      change_player
    end
  end

  def print_select_piece
    if @turn == 'white'
      puts 'SELECT PIECE(WHITE): '.colorize(color: :yellow)
    else
      puts 'SELECT PIECE(BLACK): '.colorize(color: :yellow)
    end
  end

  def print_move_to
    if @turn == 'white'
      puts 'MOVE TO(WHITE): '.colorize(color: :yellow)
    else
      puts 'MOVE TO(BLACK): '.colorize(color: :yellow)
    end
  end

  def change_player
    @turn = 'black' if @selected_piece.side == 'white'
    @turn = 'white' if @selected_piece.side == 'black'
  end
end

Chess.new
# rubocop:enable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize
# EOF
