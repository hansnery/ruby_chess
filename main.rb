# frozen_string_literal: true

# :nodoc:
# rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize
class Chess
  Dir["#{File.dirname(__FILE__)}/lib/*.rb"].sort.each { |file| require file }
  require 'colorize'
  include BoardMethods

  def initialize
    @check = false
    @turn = 'black'
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
    # clear_highlighted_tiles(@tiles_in_check) unless @tiles_in_check.nil?
    @moving = true
    ask_input
  end

  def moving(input)
    check_move(input)
    move(input)
    check_if_still_in_check if @check == true
    check_kings_safety
    change_player
    @moving = false
    ask_input
  end

  def try_again(because)
    puts "\nWrong input! Try again!".colorize(color: :yellow) if because == 'wrong_input'
    puts "\nIt\'s white\'s turn!".colorize(color: :yellow) if because == 'whites_turn'
    puts "\nIt\'s black\'s turn!".colorize(color: :yellow) if because == 'blacks_turn'
    puts "\nThis piece can\'t move! Choose another one.".colorize(color: :yellow) if because == 'cant_move'
    puts "\nCan\'t move to the same place!".colorize(color: :yellow) if because == 'cant_move_to_same_place'
    puts "\nKing is still in check! Try another move.".colorize(color: :yellow) if because == 'king_still_in_check'
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

  def select_piece(longitude, latitude)
    @selected_piece = find_piece(longitude, latitude)
    @selected_tile = find_tile(longitude, latitude)
    @selected_tile.selected = true
  end

  def show_possible_moves
    @highlighted_tiles = []
    pawn_moves if @selected_piece.instance_of?(Pawn)
    piece_cant_move if @selected_piece.instance_of?(Pawn) && @highlighted_tiles.empty? && @moving == false
    longitudinal_and_transverse_moves if piece_moves_longitudinally_or_transversally?(@selected_piece)
    piece_cant_move if @highlighted_tiles.empty? && piece_moves_longitudinally_or_transversally?(@selected_piece)
    knight_moves if @selected_piece.instance_of?(Knight)
    @line_of_sight = [] if @selected_piece.instance_of?(King)
    @tiles_in_check = [] if @selected_piece.instance_of?(King)
    king_check if @selected_piece.instance_of?(King)
    check_for_surrounding_king(@selected_piece) if @selected_piece.instance_of?(King)
  end

  def piece_moves_longitudinally_or_transversally?(piece)
    piece.instance_of?(Rook) ||
      piece.instance_of?(Bishop) ||
      piece.instance_of?(Queen) ||
      piece.instance_of?(King)
  end

  def pawn_moves
    pawn_checks
    @selected_piece.possible_moves.map do |move|
      tile = find_tile(@target_longitude + move[0], @target_latitude + move[1])
      highlight_tile(tile) if inside_the_board?(tile) && (tile.empty? || front_of_pawn?(tile, move))
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
    end
  end

  def king_check
    @pieces.map do |piece|
      next if piece.side == @selected_piece.side || piece.longitude.nil? || !piece.instance_of?(Pawn)

      king_check_for_pawns(piece)
      # clear_highlighted_tiles(@line_of_sight)
    end
    @pieces.map do |piece|
      next if piece.side == @selected_piece.side || piece.longitude.nil? || piece.instance_of?(Pawn)

      king_check_for_others(piece)
      # clear_highlighted_tiles(@line_of_sight)
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
    piece.possible_moves.map do |direction|
      king_check_direction(piece, direction)
      check_for_near_queen(piece, @selected_piece) if piece.instance_of?(Queen)
      clear_highlighted_tiles(@line_of_sight)
    end
  end

  def king_check_direction(piece, direction)
    direction.map do |move|
      tile = find_tile(piece.longitude + move[0], piece.latitude + move[1])
      next unless inside_the_board?(tile)

      target_king = find_piece(letter_to_number(tile.longitude), tile.latitude)
      @line_of_sight << tile if @highlighted_tiles.include?(tile)
      next if target_king.instance_of?(King) && target_king.side != piece.side
      break unless tile.empty?

      @line_of_sight << tile unless @line_of_sight.include?(tile)
    end
    # @line_of_sight.map { |n| puts "#{n.longitude}, #{n.latitude}"}
  end

  def check_king(king, method)
    @check = method
    king.check = method
  end

  def uncheck_king
    return if @king_in_check.nil?

    @king_in_check.check = false
    @king_in_check = nil
  end

  def find_king_in_check
    @pieces.map do |piece|
      @king_in_check = piece if piece.instance_of?(King) && piece.check?
    end
  end

  def check_kings_safety
    @check = false
    check_for_check(@white_king)
    check_for_check(@black_king)
    display_check_message if @check == true
  end

  def check_for_check(king)
    check_kings_surroundings(king)
    check_kings_line_of_sight(king)
  end

  def check_kings_surroundings(king)
    possible_moves = king.possible_moves.flatten(1)
    possible_moves.map do |move|
      piece = find_piece(king.longitude + move[0], king.latitude + move[1])
      next if piece.nil? || piece.side == king.side

      check_king(king, check_for_surrounding_pawns(piece, king))
      break if @check == true
    end
  end

  def check_for_surrounding_pawns(piece, king)
    (piece.longitude == king.longitude - 1 ||
      piece.longitude == king.longitude + 1) &&
      ((piece.latitude == king.latitude + 1 && piece.side == 'black') ||
      (piece.latitude == king.latitude - 1 && piece.side == 'white')) &&
      piece.side != king.side && piece.instance_of?(Pawn)
  end

  def check_for_near_queen(queen, king)
    remove_king_left_upper_and_bottom_tiles(king) if queen.longitude == king.longitude - 1 &&
                                                     queen.latitude == king.latitude
    remove_king_right_upper_and_bottom_tiles(king) if queen.longitude == king.longitude + 1 &&
                                                      queen.latitude == king.latitude
    remove_king_upper_left_and_right_tiles(king) if queen.latitude == king.latitude + 1 &&
                                                    queen.longitude == king.longitude
    remove_king_bottom_left_and_right_tiles(king) if queen.latitude == king.latitude - 1 &&
                                                     queen.longitude == king.longitude
  end

  def remove_king_left_upper_and_bottom_tiles(king)
    tiles_to_remove = []
    tiles_to_remove << find_tile(king.longitude, king.latitude + 1)
    tiles_to_remove << find_tile(king.longitude - 1, king.latitude + 1)
    tiles_to_remove << find_tile(king.longitude, king.latitude - 1)
    tiles_to_remove << find_tile(king.longitude - 1, king.latitude - 1)
    clear_highlighted_tiles(tiles_to_remove)
  end

  def remove_king_right_upper_and_bottom_tiles(king)
    tiles_to_remove = []
    tiles_to_remove << find_tile(king.longitude, king.latitude + 1)
    tiles_to_remove << find_tile(king.longitude + 1, king.latitude + 1)
    tiles_to_remove << find_tile(king.longitude, king.latitude - 1)
    tiles_to_remove << find_tile(king.longitude + 1, king.latitude - 1)
    clear_highlighted_tiles(tiles_to_remove)
  end

  def remove_king_upper_left_and_right_tiles(king)
    tiles_to_remove = []
    tiles_to_remove << find_tile(king.longitude - 1, king.latitude)
    tiles_to_remove << find_tile(king.longitude - 1, king.latitude + 1)
    tiles_to_remove << find_tile(king.longitude + 1, king.latitude)
    tiles_to_remove << find_tile(king.longitude + 1, king.latitude + 1)
    clear_highlighted_tiles(tiles_to_remove)
  end

  def remove_king_bottom_left_and_right_tiles(king)
    tiles_to_remove = []
    tiles_to_remove << find_tile(king.longitude - 1, king.latitude)
    tiles_to_remove << find_tile(king.longitude - 1, king.latitude - 1)
    tiles_to_remove << find_tile(king.longitude + 1, king.latitude)
    tiles_to_remove << find_tile(king.longitude + 1, king.latitude - 1)
    clear_highlighted_tiles(tiles_to_remove)
  end

  def check_kings_line_of_sight(king)
    check_cardinal_directions(king)
    check_intercardinal_directions(king)
  end

  def check_cardinal_directions(king)
    king.cardinal_directions.map do |direction|
      direction.map do |tile|
        piece = find_piece(king.longitude + tile[0], king.latitude + tile[1])
        next if piece.nil?
        break if piece.side == king.side || (piece.side != king.side && piece.instance_of?(Pawn) ||
                 piece.instance_of?(Knight) || piece.instance_of?(Bishop) || piece.instance_of?(King))

        check_king(king, check_for_cardinal_danger(piece, king))
        clear_tiles_in_check(piece, king, direction) if check_for_cardinal_danger(piece, king)
      end
    end
  end

  def check_intercardinal_directions(king)
    king.intercardinal_directions.map do |direction|
      direction.map do |tile|
        piece = find_piece(king.longitude + tile[0], king.latitude + tile[1])
        next if piece.nil?
        break if piece.side == king.side || (piece.side != king.side && piece.instance_of?(Pawn) ||
                 piece.instance_of?(Knight) || piece.instance_of?(Rook) || piece.instance_of?(King))

        check_king(king, check_for_intercardinal_danger(piece, king))
        clear_tiles_in_check(piece, king, direction) if check_for_intercardinal_danger(piece, king)
      end
    end
  end

  def check_for_cardinal_danger(piece, king)
    piece.side != king.side && piece.instance_of?(Rook) || piece.instance_of?(Queen)
  end

  def check_for_intercardinal_danger(piece, king)
    piece.side != king.side && piece.instance_of?(Queen) || piece.instance_of?(Bishop)
  end

  def check_for_surrounding_king(king)
    @pieces.map do |piece|
      next unless piece.instance_of?(King) && piece.side != king.side

      @line_of_sight = []
      other_king_moves = piece.possible_moves.flatten(1)
      other_king_moves.map do |move|
        tile = find_tile(piece.longitude + move[0], piece.latitude + move[1])
        @line_of_sight << tile
      end
      clear_highlighted_tiles(@line_of_sight)
    end
  end

  def check_if_still_in_check
    check_kings_safety
    find_king_in_check
    uncheck_king if @check == false
    return if @check == false || @turn != @king_in_check.side

    select_piece(@target_longitude, @target_latitude)
    move_piece(letter_to_longitude(@last_input[0]), @last_input[1].to_i)
    clear_board
    @moving = false
    @selected_piece.moved_once = false if @selected_piece.instance_of?(Pawn)
    try_again('king_still_in_check') if @check == true
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

  def display_check_message
    puts "\nCHECK!".colorize(color: :yellow) if @check == true
  end

  def inside_the_board?(tile)
    return true if tile.respond_to?(:longitude) && tile.respond_to?(:latitude)
  end

  def same_place?(input)
    input == number_to_letter(@selected_piece.longitude) + @selected_piece.latitude.to_s
  end

  def capture_piece
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
    capture_piece
  end

  def move(input)
    @highlighted_tiles.map do |tile|
      longitude = tile.longitude.to_s
      latitude = tile.latitude.to_s
      next unless input == longitude + latitude

      move_piece(letter_to_longitude(longitude), latitude.to_i)
      clear_board
      @selected_piece.moved_once = true if @selected_piece.instance_of?(Pawn) && @selected_piece.moved_once == false
    end
  end

  def print_select_piece
    # @highlighted_tiles.map { |n| puts "#{n.data} #{n.longitude}, #{n.latitude}" } unless @highlighted_tiles.nil?
    puts "\nCheck: #{@check}\nTurn: #{@turn}"
    if @turn == 'white'
      puts 'SELECT PIECE(WHITE): '.colorize(color: :yellow)
    else
      puts 'SELECT PIECE(BLACK): '.colorize(color: :yellow)
    end
  end

  def print_move_to
    # @highlighted_tiles.map { |n| puts "#{n.data} #{n.longitude}, #{n.latitude}" } unless @highlighted_tiles.nil?
    puts "\nCheck: #{@check}\nTurn: #{@turn}"
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
