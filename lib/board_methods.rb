# frozen_string_literal: true

# :nodoc:
# rubocop:disable Metrics/AbcSize
module BoardMethods
  def letter_to_longitude(input_letter)
    board_letters = ('a'..'h').to_a
    board_letters.each_with_index do |board_letter, index|
      return index + 1 if input_letter == board_letter
    end
  end

  def position_piece(piece)
    corrected_latitude = (8 - piece.latitude)
    corrected_longitude = (piece.longitude - 1)
    @board.rows[corrected_latitude][corrected_longitude].data = piece.data
    @board.rows[corrected_latitude][corrected_longitude].side = piece.side
  end

  def position_pieces(pieces_array)
    pieces_array.map { |piece| position_piece(piece) }
  end

  def set_target(longitude, latitude)
    @root = [@selected_piece.longitude, @selected_piece.latitude]
    @target = @board.rows[8 - latitude][longitude - 1]
    @target_coordinate = target_coordinate(longitude, latitude)
  end

  def move_piece(piece, tile, new_longitude, new_latitude)
    empty_tile(tile)
    piece.longitude = new_longitude
    piece.latitude = new_latitude
    @board.rows[8 - new_latitude][new_longitude - 1].data = piece.data
    @board.rows[8 - new_latitude][new_longitude - 1].side = piece.side
  end

  def target_coordinate(longitude, latitude, distance = [])
    distance << longitude
    distance << latitude
    distance
  end

  def target_distance
    result = []
    @piece_coordinate = []
    @piece_coordinate << @piece.longitude
    @piece_coordinate << @piece.latitude
    result << @target_coordinate[0] - @piece_coordinate[0]
    result << @target_coordinate[1] - @piece_coordinate[1]
    result
  end

  def target_reached?(piece)
    return true if piece.longitude == @target_coordinate[0] && piece.latitude == @target_coordinate[1]
  end

  def empty_tile(tile)
    tile.data = '  '
    tile.side = nil
  end

  def clear_board
    @selected_tile.selected = false
    @highlighted_tiles.map do |tile|
      tile.highlighted = false
    end
  end

  def valid_move?(new_longitude, new_latitude, piece)
    return false if out_of_the_board?

    piece.possible_moves.each do |move|
      return true if move[0] == (new_longitude - piece.longitude) && move[1] == (new_latitude - piece.latitude)
    end
  end

  def out_of_the_board?
    new_longitude > 8 || new_longitude < 1 || new_latitude > 8 || new_latitude < 1
  end

  def letter_to_number(letter)
    @board.board_letters.each_with_index do |board_letter, index|
      return index + 1 if board_letter == letter
    end
  end

  def number_to_letter(number)
    @board.board_letters.each_with_index do |board_letter, index|
      return board_letter if number - 1 == index
    end
  end

  def find_piece(longitude, latitude)
    @pieces.map do |piece|
      return piece if piece.longitude == longitude && piece.latitude == latitude
    end
    nil
  end

  def find_tile(longitude, latitude)
    @board.rows.each do |row|
      row.each do |tile|
        return tile if tile.longitude == number_to_letter(longitude) && tile.latitude == latitude
      end
    end
  end

  def highlight_tile(tile)
    tile.highlighted = true
    @highlighted_tiles << tile
  end
end
# rubocop:enable Metrics/AbcSize
# EOF
