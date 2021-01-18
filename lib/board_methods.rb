# frozen_string_literal: true

# :nodoc:
module BoardMethods
  def letter_to_longitude(input_letter)
    board_letters = ('a'..'h').to_a
    board_letters.each_with_index do |board_letter, index|
      return index + 1 if input_letter == board_letter
    end
  end

  def position_piece(piece)
    @piece = piece
    corrected_latitude = (8 - @piece.latitude)
    corrected_longitude = (@piece.longitude - 1)
    @board.rows[corrected_latitude][corrected_longitude].data = @piece.data
    @board.rows[corrected_latitude][corrected_longitude].visited = true
  end

  def position_pieces(pieces_array)
    pieces_array.map { |piece| position_piece(piece) }
  end

  def set_target(longitude, latitude)
    @root = [@piece.longitude, @piece.latitude]
    @target = @board.rows[8 - latitude][longitude - 1]
    @target_coordinate = target_coordinate(longitude, latitude)
  end

  def move_piece(new_longitude, new_latitude)
    empty_tile
    @piece.longitude = new_longitude
    @piece.latitude = new_latitude
    p @piece
    update_position(@piece.longitude, @piece.latitude)
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

  def target_reached?
    return true if @piece.longitude == @target_coordinate[0] && @piece.latitude == @target_coordinate[1]
  end

  def empty_tile
    @rows[8 - @piece.latitude][@piece.longitude - 1].data = '  '
  end

  def update_position(longitude, latitude)
    # empty_tile
    @piece.longitude = longitude
    @piece.latitude = latitude
    @board.rows[8 - latitude][longitude - 1].data = @piece.data
    @board.print_board
  end

  def valid_move?(new_longitude, new_latitude)
    return false if new_longitude > 8 || new_longitude < 1 || new_latitude > 8 || new_latitude < 1

    @piece.possible_moves.each do |move|
      return true if move[0] == (new_longitude - @piece.longitude) && move[1] == (new_latitude - @piece.latitude)
    end
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

  def find_tile(longitude, latitude)
    @board.rows.each do |row|
      row.each do |el|
        return el if el.longitude == number_to_letter(longitude) && el.latitude == latitude
      end
    end
  end

  def display_rows
    @board.rows.each do |row|
      row.each do |el|
        p el
      end
    end
  end
end
