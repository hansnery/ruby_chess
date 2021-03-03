# frozen_string_literal: true

# :nodoc:
class Chess
  Dir["#{File.dirname(__FILE__)}/lib/*.rb"].sort.each { |file| require file }
  require 'colorize'
  require 'yaml'
  include BoardMethods
  include Pieces
  include Console
  include Castling
  include Check
  include Checkmate
  include KingMovementsLimits
  include Promotion
  include Movement

  def initialize
    @check = false
    @checkmate = false
    @turn = 'white'
    @moving = false
    welcome
    @board = Board.new
    setup_pieces
    ask_input
  end

  def play_round(input)
    if @moving == false
      playing(input)
    else
      moving(input)
    end
  end

  def playing(input)
    @last_input = input
    check_tile_and_piece
    select_piece(@target_longitude, @target_latitude)
    show_possible_moves
    @moving = true
    ask_input
  end

  def moving(input)
    castling(input) if @selected_piece.instance_of?(King)
    check_move(input)
    move(input)
    promote_pawn if @selected_piece.instance_of?(Pawn) && pawn_can_be_promoted?
    check_if_still_in_check if @check == true
    check_kings_safety
    change_player
    @moving = false
    ask_input
  end

  def select_piece(longitude, latitude)
    @selected_piece = find_piece(longitude, latitude)
    @selected_tile = find_tile(longitude, latitude)
    @selected_tile.selected = true
  end

  def clear_highlighted_tiles(array)
    @highlighted_tiles.each_with_index do |tile, idx|
      @highlighted_tiles.delete_at(idx) if array.include?(tile)
      tile.highlighted = false if array.include?(tile)
    end
  end

  def collect_tiles_for_clearing(piece, king, array)
    tiles_to_clear = []
    array.map do |tile|
      tile = find_tile(king.longitude + tile[0], king.latitude + tile[1])
      break if tile.data == piece.data && tile.instance_of?(Tile)

      tiles_to_clear << tile unless tile.nil?
    end
    tiles_to_clear
  end

  def clear_tiles_in_check(piece, king, array)
    tiles_to_clear = collect_tiles_for_clearing(piece, king, array)
    @tiles_in_check = tiles_to_clear
  end

  def inside_the_board?(tile)
    return true if tile.respond_to?(:longitude) && tile.respond_to?(:latitude)
  end

  def same_place?(input)
    input == number_to_letter(@selected_piece.longitude) + @selected_piece.latitude.to_s
  end

  def check_move(input)
    try_again('cant_move_to_same_place') if same_place?(input)
    check_tile_and_piece
    capture_piece
  end

  def capture_piece
    piece = find_piece(@target_longitude, @target_latitude)
    return if piece.nil?

    piece.longitude = nil
    piece.latitude = nil
  end
end

Chess.new
# EOF
