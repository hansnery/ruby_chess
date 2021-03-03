# frozen_string_literal: true

# :nodoc:
# rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize
module Check
  def check_king(king, piece, method)
    @check = method
    @piece_checking_king = piece
    king.check = method
  end

  def uncheck_king
    return if @king_in_check.nil?

    @king_in_check.check = false
    @king_in_check = nil
    @piece_checking_king = nil
  end

  def check_kings_safety
    @check = false
    check_for_check(@white_king)
    check_for_check(@black_king)
    display_check_message if @check == true && @checkmate == false
    check_for_checkmate if @check == true
  end

  def check_for_check(king)
    check_kings_surroundings(king)
    check_kings_far_surroundings(king)
    check_cardinal_directions(king)
    check_intercardinal_directions(king)
  end

  def check_kings_surroundings(king)
    possible_moves = king.possible_moves.flatten(1)
    possible_moves.map do |move|
      piece = find_piece(king.longitude + move[0], king.latitude + move[1])
      next if piece.nil? || piece.side == king.side

      check_king(king, piece, check_for_surrounding_pawns(piece, king))
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

  def check_kings_far_surroundings(king)
    @pieces.map do |piece|
      break if @check == true

      next unless piece.instance_of?(Knight) && piece.side != king.side

      check_king(king, piece, check_for_surrounding_knights(piece, king))
      break if @check == true
    end
  end

  def check_for_surrounding_knights(piece, king)
    (piece.longitude == king.longitude + 1 && piece.latitude == king.latitude + 2) ||
      (piece.longitude == king.longitude + 2 && piece.latitude == king.latitude + 1) ||
      (piece.longitude == king.longitude + 2 && piece.latitude == king.latitude - 1) ||
      (piece.longitude == king.longitude + 1 && piece.latitude == king.latitude - 2) ||
      (piece.longitude == king.longitude - 1 && piece.latitude == king.latitude - 2) ||
      (piece.longitude == king.longitude - 2 && piece.latitude == king.latitude - 1) ||
      (piece.longitude == king.longitude - 2 && piece.latitude == king.latitude + 1) ||
      (piece.longitude == king.longitude - 1 && piece.latitude == king.latitude + 2) &&
        piece.side != king.side && piece.instance_of?(Knight)
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

  def check_cardinal_directions(king)
    king.cardinal_directions.map do |direction|
      direction.map do |tile|
        piece = find_piece(king.longitude + tile[0], king.latitude + tile[1])
        next if piece.nil?
        break if piece.side == king.side || (piece.side != king.side && piece.instance_of?(Pawn) ||
                 piece.instance_of?(Knight) || piece.instance_of?(Bishop) || piece.instance_of?(King))

        check_king(king, piece, check_for_cardinal_danger(piece, king))
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

        check_king(king, piece, check_for_intercardinal_danger(piece, king))
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
end
# rubocop:enable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize
# EOF
