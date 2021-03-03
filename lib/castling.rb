# frozen_string_literal: true

# :nodoc:
# rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize
module Castling
  def add_castling_moves
    highlight_short_castling_tiles
    highlight_long_castling_tiles
  end

  def highlight_short_castling_tiles
    if @turn == 'white' && white_castling_short?
      highlight_tile(find_tile(6, 1))
      highlight_tile(find_tile(7, 1))
    elsif @turn == 'black' && black_castling_short?
      highlight_tile(find_tile(6, 8))
      highlight_tile(find_tile(7, 8))
    end
  end

  def highlight_long_castling_tiles
    if @turn == 'white' && white_castling_long?
      highlight_tile(find_tile(2, 1))
      highlight_tile(find_tile(4, 1))
    elsif @turn == 'black' && black_castling_long?
      highlight_tile(find_tile(2, 8))
      highlight_tile(find_tile(4, 8))
    end
  end

  def white_castling_long?
    @long_castle_tiles = []
    first_tile = find_tile(2, 1)
    second_tile = find_tile(3, 1)
    third_tile = find_tile(4, 1)
    return false unless !@white_rook1.moved? && !@white_king.moved? && first_tile.empty? &&
                        second_tile.empty? && third_tile.empty?

    @long_castle_tiles << first_tile
    @long_castle_tiles << second_tile
    @long_castle_tiles << third_tile
    return true if castling_tiles_not_in_danger?(@long_castle_tiles)
  end

  def black_castling_long?
    @long_castle_tiles = []
    first_tile = find_tile(2, 8)
    second_tile = find_tile(3, 8)
    third_tile = find_tile(4, 8)
    return false unless !@black_rook1.moved? && !@black_king.moved? && first_tile.empty? &&
                        second_tile.empty? && third_tile.empty?

    @long_castle_tiles << first_tile
    @long_castle_tiles << second_tile
    @long_castle_tiles << third_tile
    return true if castling_tiles_not_in_danger?(@long_castle_tiles)
  end

  def white_castling_short?
    @short_castle_tiles = []
    first_tile = find_tile(6, 1)
    second_tile = find_tile(7, 1)
    return false unless !@white_rook2.moved? && !@white_king.moved? && first_tile.empty? && second_tile.empty?

    @short_castle_tiles << first_tile
    @short_castle_tiles << second_tile
    return true if castling_tiles_not_in_danger?(@short_castle_tiles)
  end

  def black_castling_short?
    @short_castle_tiles = []
    first_tile = find_tile(6, 8)
    second_tile = find_tile(7, 8)
    return false unless !@black_rook2.moved? && !@black_king.moved? && first_tile.empty? && second_tile.empty?

    @short_castle_tiles << first_tile
    @short_castle_tiles << second_tile
    return true if castling_tiles_not_in_danger?(@short_castle_tiles)
  end

  def castling_tiles_not_in_danger?(array)
    @pieces.map do |piece|
      piece.possible_moves.map do |direction|
        next if piece.side == @turn

        direction.map do |move|
          tile = find_tile(piece.longitude + move[0], piece.latitude + move[1])
          break if tile.instance_of?(Array) || tile.not_empty?

          return false if array.include?(tile)
        end
      end
    end
  end

  def white_castling(input)
    if input == 'g1' && white_castling_short?
      tile = find_tile(@white_rook2.longitude, @white_rook2.latitude)
      move_piece(@white_rook2, tile, 6, 1)
      move_piece(@black_rook2, tile, 6, 8)
    elsif input == 'b1' && white_castling_long?
      tile = find_tile(@white_rook1.longitude, @white_rook1.latitude)
      move_piece(@white_rook1, tile, 3, 1)
    end
  end

  def black_castling(input)
    if input == 'g8' && black_castling_short?
      tile = find_tile(@black_rook2.longitude, @black_rook2.latitude)
      move_piece(@black_rook2, tile, 6, 8)
    elsif input == 'b8' && black_castling_long?
      tile = find_tile(@black_rook1.longitude, @black_rook1.latitude)
      move_piece(@black_rook1, tile, 3, 8)
    end
  end

  def castling(input)
    white_castling(input)
    black_castling(input)
  end
end
# rubocop:enable Metrics/CyclomaticComplexity,Metrics/AbcSize
# EOF
