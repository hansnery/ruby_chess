# frozen_string_literal: true

# :nodoc:
class Rook
  attr_accessor :longitude, :latitude, :data, :moved_once, :side
  attr_reader :possible_moves

  def initialize(longitude, latitude, side)
    @longitude = longitude
    @latitude = latitude
    @side = side
    @moved_once = false
    @possible_moves = [[[0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7]],
                       [[1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0]],
                       [[0, -1], [0, -2], [0, -3], [0, -4], [0, -5], [0, -6], [0, -7]],
                       [[-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0]]]
    set_character
  end

  def set_character
    @data = if side == 'white'
              '♖ '
            else
              '♜ '
            end
  end

  def moved?
    @moved_once
  end
end
