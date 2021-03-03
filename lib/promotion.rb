# frozen_string_literal: true

# :nodoc:
module Promotion
  def pawn_can_be_promoted?
    @selected_piece.latitude == 8 && @turn == 'white' ||
      @selected_piece.latitude == 1 && @turn == 'black'
  end

  def promote_pawn
    puts "\n[1] KNIGHT\n[2] BISHOP\n[3] ROOK\n[4] QUEEN\nPROMOTE PAWN TO:\n".colorize(color: :yellow)
    input = gets.chomp
    capture_piece
    piece = switch_piece(input)
    position_piece(piece)
    @pieces << piece
  end

  def switch_piece(input)
    case input
    when '1'
      Knight.new(@target_longitude, @target_latitude, @turn)
    when '2'
      Bishop.new(@target_longitude, @target_latitude, @turn)
    when '3'
      Rook.new(@target_longitude, @target_latitude, @turn)
    when '4'
      Queen.new(@target_longitude, @target_latitude, @turn)
    end
  end
end
# EOF
