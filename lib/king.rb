# frozen_string_literal: true

# :nodoc:
class King
  include BoardMethods
  attr_accessor :longitude, :latitude, :data, :side, :check
  attr_reader :possible_moves, :cardinal_directions, :intercardinal_directions

  def initialize(longitude, latitude, side)
    @longitude = longitude
    @latitude = latitude
    @possible_moves = [[[0, 1]], [[1, 1]], [[1, 0]], [[1, -1]], [[0, -1]], [[-1, -1]], [[-1, 0]], [[-1, 1]]]
    @side = side
    @check = false
    set_character
    set_line_of_sight
  end

  def set_character
    @data = if side == 'white'
              '♔ '
            else
              '♚ '
            end
  end

  def set_line_of_sight
    @cardinal_directions = [[[0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7]],
                            [[1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0]],
                            [[0, -1], [0, -2], [0, -3], [0, -4], [0, -5], [0, -6], [0, -7]],
                            [[-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0]]]
    @intercardinal_directions = [[[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7]],
                                 [[1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7]],
                                 [[-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]],
                                 [[-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7]]]
  end

  def check?
    @check
  end
end
