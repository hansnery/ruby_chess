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

  def move_piece(new_longitude, new_latitude)
    empty_tile
    @selected_piece.longitude = new_longitude
    @selected_piece.latitude = new_latitude
    @board.rows[8 - new_latitude][new_longitude - 1].data = @selected_piece.data
    @board.rows[8 - new_latitude][new_longitude - 1].side = @selected_piece.side
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

  def empty_tile
    @selected_tile.data = '  '
    @selected_tile.side = nil
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

  def display_rows
    @board.rows.each do |row|
      row.each do |el|
        p el
      end
    end
  end

  def setup_pieces
    @pieces = []
    black_first_row.map { |piece| @pieces << piece }
    black_second_row.map { |piece| @pieces << piece }
    white_first_row.map { |piece| @pieces << piece }
    white_second_row.map { |piece| @pieces << piece }
    @pieces.map { |piece| piece.longitude = letter_to_number(piece.longitude) }
    position_pieces(@pieces)
  end

  def black_first_row
    [
      @black_pawn1 = Pawn.new('a', 7, 'black'), @black_pawn2 = Pawn.new('b', 7, 'black'),
      @black_pawn3 = Pawn.new('c', 7, 'black'), @black_pawn4 = Pawn.new('d', 7, 'black'),
      @black_pawn5 = Pawn.new('e', 7, 'black'), @black_pawn6 = Pawn.new('f', 7, 'black'),
      @black_pawn7 = Pawn.new('g', 7, 'black'), @black_pawn8 = Pawn.new('h', 7, 'black')
    ]
  end

  def black_second_row
    [
      @black_rook1 = Rook.new('a', 8, 'black'), @black_rook2 = Rook.new('h', 8, 'black'),
      @black_knight1 = Knight.new('b', 8, 'black'), @black_knight2 = Knight.new('g', 8, 'black'),
      @black_bishop1 = Bishop.new('c', 8, 'black'), @black_bishop2 = Bishop.new('f', 8, 'black'),
      @black_king = King.new('e', 8, 'black'), @black_queen = Queen.new('d', 8, 'black')
    ]
  end

  def white_first_row
    [
      @white_pawn1 = Pawn.new('a', 2, 'white'), @white_pawn2 = Pawn.new('b', 2, 'white'),
      @white_pawn3 = Pawn.new('c', 2, 'white'), @white_pawn4 = Pawn.new('d', 2, 'white'),
      @white_pawn5 = Pawn.new('e', 2, 'white'), @white_pawn6 = Pawn.new('f', 2, 'white'),
      @white_pawn7 = Pawn.new('g', 2, 'white'), @white_pawn8 = Pawn.new('h', 2, 'white')
    ]
  end

  def white_second_row
    [
      @white_rook1 = Rook.new('a', 1, 'white'), @white_rook2 = Rook.new('h', 1, 'white'),
      @white_knight1 = Knight.new('b', 1, 'white'), @white_knight2 = Knight.new('g', 1, 'white'),
      @white_bishop1 = Bishop.new('c', 1, 'white'), @white_bishop2 = Bishop.new('f', 1, 'white'),
      @white_king = King.new('e', 1, 'white'), @white_queen = Queen.new('d', 1, 'white')
    ]
  end

  def highlight_tile(tile)
    tile.highlighted = true
    @highlighted_tiles << tile
  end
end
# rubocop:enable Metrics/AbcSize
# EOF
