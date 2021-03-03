# frozen_string_literal: true

# :nodoc:
# rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize
module KingMovementsLimits
  def king_check
    @pieces.map do |piece|
      next if piece.side == @selected_piece.side || piece.longitude.nil? || !piece.instance_of?(Pawn)

      king_check_for_pawns(piece)
    end
    @pieces.map do |piece|
      next if piece.side == @selected_piece.side || piece.longitude.nil? || piece.instance_of?(Pawn) ||
              piece.instance_of?(Knight)

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
end
# rubocop:enable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize
# EOF
