# frozen_string_literal: true

# :nodoc:
class Bishop
  attr_accessor :longitude, :latitude, :data, :side
  attr_reader :possible_moves

  def initialize(longitude, latitude, side)
    @longitude = longitude
    @latitude = latitude
    @possible_moves = [[[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7]],
                       [[1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7]],
                       [[-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]],
                       [[-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7]]]
    @side = side
    set_character
  end

  def set_character
    @data = if side == 'white'
              '♗ '
            else
              '♝ '
            end
  end
end
