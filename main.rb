# frozen_string_literal: true

# :nodoc:
# rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize
class Chess
  Dir["#{File.dirname(__FILE__)}/lib/*.rb"].sort.each { |file| require file }
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

  def piece_cant_move
    clear_board
    try_again('cant_move')
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
    longitudinal_and_transverse_moves if piece_moves_longitudinally_or_transversally?
    piece_cant_move if @highlighted_tiles.empty? && piece_moves_longitudinally_or_transversally?
    knight_moves if @selected_piece.instance_of?(Knight)
    king_check if @selected_piece.instance_of?(King)
  end

  def piece_moves_longitudinally_or_transversally?
    @selected_piece.instance_of?(Rook) ||
      @selected_piece.instance_of?(Bishop) ||
      @selected_piece.instance_of?(Queen) ||
      @selected_piece.instance_of?(King)
  end

  def pawn_moves
    pawn_checks
    @selected_piece.possible_moves.map do |move|
      tile = find_tile(@target_longitude + move[0], @target_latitude + move[1])
      highlight_tile(tile) if inside_the_board?(tile) && (tile.empty? || front_of_pawn?(tile, move))
      next unless @highlighted_tiles.empty?

      piece_cant_move
    end
  end

  def check_for_pawn_diagonals
    @selected_piece.diagonal_attack.map do |move|
      piece = find_piece(@target_longitude + move[0], @target_latitude + move[1])
      tile = find_tile(@target_longitude + move[0], @target_latitude + move[1])
      next unless inside_the_board?(tile) && tile.not_empty? && piece.side != @selected_piece.side

      highlight_tile(tile)
    end
  end

  def pawn_checks
    check_for_pawn_diagonals
    @selected_piece.possible_moves.map do |move|
      tile = find_tile(@target_longitude + move[0], @target_latitude + move[1])
      @selected_piece.possible_moves.shift if @selected_piece.jumped? || tile.not_empty?
    end
  end

  def front_of_pawn?(tile, move)
    tile.not_empty? && move[1] != 1 && move[1] != -1
  end

  def longitudinal_and_transverse_moves
    @selected_piece.possible_moves.map do |direction|
      direction.map do |move|
        piece = find_piece(@target_longitude + move[0], @target_latitude + move[1])
        tile = find_tile(@target_longitude + move[0], @target_latitude + move[1])
        highlight_tile(tile) if inside_the_board?(tile) && tile.empty?
        next unless inside_the_board?(tile) && tile.not_empty?

        highlight_tile(tile) if piece.side != @selected_piece.side
        break
      end
    end
  end

  def knight_moves
    @selected_piece.possible_moves.map do |move|
      piece = find_piece(@target_longitude + move[0], @target_latitude + move[1])
      tile = find_tile(@target_longitude + move[0], @target_latitude + move[1])
      highlight_tile(tile) if inside_the_board?(tile) && (tile.empty? || piece.side != @selected_piece.side)
      next unless @highlighted_tiles.empty?

      piece_cant_move
    end
  end

  def king_check
    @line_of_sight = []
    @pieces.map do |piece|
      # @line_of_sight = []
      next if piece.side == @selected_piece.side || piece.longitude.nil?

      king_check_for_pawns(piece)
    end
    @pieces.map do |piece|
      # @line_of_sight = []
      next if piece.side == @selected_piece.side || piece.longitude.nil? || piece.instance_of?(Pawn)

      king_check_for_others(piece)
    end
  end

  def king_check_for_pawns(piece)
    return unless piece.instance_of?(Pawn)

    piece.diagonal_attack.map do |move|
      tile = find_tile(piece.longitude + move[0], piece.latitude + move[1])
      break unless inside_the_board?(tile)

      @line_of_sight << tile
    end
    clear_highlighted_tiles(@line_of_sight)
  end

  def king_check_for_others(piece)
    return if piece.instance_of?(Pawn)

    piece.possible_moves.map do |direction|
      direction.map do |move|
        tile = find_tile(piece.longitude + move[0], piece.latitude + move[1])
        # piece_in_los = find_piece(piece.longitude + move[0], piece.latitude + move[1])
        @line_of_sight << tile if @highlighted_tiles.include?(tile)
        break unless inside_the_board?(tile) & tile.empty?

        @line_of_sight << tile
      end
      clear_highlighted_tiles(@line_of_sight)
    end
  end

  def clear_highlighted_tiles(array)
    @highlighted_tiles.each_with_index do |tile, idx|
      @highlighted_tiles.delete_at(idx) if array.include?(tile)
      tile.highlighted = false if array.include?(tile)
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
