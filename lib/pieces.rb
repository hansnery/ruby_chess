# frozen_string_literal: true

# :nodoc:
# rubocop:disable Metrics/AbcSize
module Pieces
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
end
# rubocop:enable Metrics/AbcSize
# EOF
