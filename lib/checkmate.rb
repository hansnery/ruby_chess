# frozen_string_literal: true

# :nodoc:
# rubocop:disable Metrics/AbcSize
module Checkmate
  def find_king_in_check
    @pieces.map do |piece|
      @king_in_check = piece if piece.instance_of?(King) && piece.check?
    end
  end

  def check_if_still_in_check
    check_kings_safety
    find_king_in_check if @check == true
    uncheck_king if @check == false
    return if @check == false || @turn != @king_in_check.side

    select_piece(@target_longitude, @target_latitude)
    move_piece(@selected_piece, @selected_tile, (@last_input[0]), @last_input[1].to_i)
    clear_board
    @moving = false
    @selected_piece.moved_once = false if @selected_piece.respond_to?(:moved?)
    try_again('king_still_in_check') if @check == true
  end

  def checkmate
    @checkmate = true
    puts "\nCHECKMATE!".colorize(color: :yellow)
    puts "\n#{@piece_checking_king.side.capitalize} wins!".colorize(color: :yellow)
    new_game?
  end

  def check_for_checkmate
    find_king_in_check
    tile_with_piece_checking_king = find_tile(@piece_checking_king.longitude, @piece_checking_king.latitude)
    select_king_to_move(@king_in_check) if no_pawn_can_save_the_king?(tile_with_piece_checking_king) &&
                                           no_other_piece_can_save_the_king?(tile_with_piece_checking_king)
  end

  def no_pawn_can_save_the_king?(tile_with_piece_checking_king)
    @pieces.map do |piece|
      next unless piece.side == @king_in_check.side && piece.instance_of?(Pawn)
      next if piece.longitude.nil?

      piece.diagonal_attack.map do |move|
        tile = find_tile(piece.longitude + move[0], piece.latitude + move[1])
        return false if tile == tile_with_piece_checking_king
      end
    end
    true
  end

  def no_other_piece_can_save_the_king?(tile_with_piece_checking_king)
    @pieces.map do |piece|
      next if piece.instance_of?(Pawn) || piece.instance_of?(King) || piece.side != @king_in_check.side
      next if piece.longitude.nil?

      return false unless piece_can_save_the_king?(piece, tile_with_piece_checking_king)
    end
    true
  end

  def piece_can_save_the_king?(piece, tile_with_piece_checking_king)
    piece.possible_moves.map do |direction|
      direction.map do |move|
        tile = find_tile(piece.longitude + move[0], piece.latitude + move[1])
        next if tile.instance_of?(Array)
        break if tile.side == piece.side

        return false if tile == tile_with_piece_checking_king
      end
    end
    true
  end
end
# rubocop:enable Metrics/AbcSize
# EOF
