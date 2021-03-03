# frozen_string_literal: true

# :nodoc:
# rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize
module Movement
  def check_tile_and_piece
    target_tile = find_tile(@target_longitude, @target_latitude)
    target_piece = find_piece(@target_longitude, @target_latitude)
    try_again('wrong_input') if target_tile.empty? && @moving == false
    try_again('wrong_input') if target_tile.highlighted == false && @moving == true
    return unless target_piece.respond_to?(:side)

    try_again('blacks_turn') if target_piece.side == 'white' && @turn != 'white' && @moving == false
    try_again('whites_turn') if target_piece.side == 'black' && @turn != 'black' && @moving == false
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
    king_moves
  end

  def king_moves
    king_check if @selected_piece.instance_of?(King)
    check_for_surrounding_king(@selected_piece) if @selected_piece.instance_of?(King)
    add_castling_moves if @selected_piece.instance_of?(King)
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
      @selected_piece.possible_moves.shift if @selected_piece.moved? || tile.not_empty?
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

  def select_king_to_move(king)
    input = number_to_letter(king.longitude).to_s + king.latitude.to_s
    @target_longitude = letter_to_longitude(input[0])
    @target_latitude = input[1].to_i
    change_player
    @moving = true
    select_piece(@target_longitude, @target_latitude)
    show_possible_moves
    checkmate if @highlighted_tiles.empty?
    ask_input unless @highlighted_tiles.empty?
  end

  def move(input)
    @highlighted_tiles.map do |tile|
      longitude = tile.longitude.to_s
      latitude = tile.latitude.to_s
      next unless input == longitude + latitude

      move_piece(@selected_piece, @selected_tile, letter_to_longitude(longitude), latitude.to_i)
      clear_board
      @selected_piece.moved_once = true if @selected_piece.respond_to?(:moved?) && @selected_piece.moved_once == false
    end
  end
end
# rubocop:enable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize
# EOF
