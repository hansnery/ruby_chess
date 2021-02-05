# frozen_string_literal: true

# :nodoc:
class King
  attr_accessor :longitude, :latitude, :data, :side
  attr_reader :possible_moves

  def initialize(longitude, latitude, side)
    @longitude = longitude
    @latitude = latitude
    @possible_moves = [[[0, 1]], [[1, 1]], [[1, 0]], [[1, -1]], [[0, -1]], [[-1, -1]], [[-1, 0]], [[-1, 1]]]
    @side = side
    set_character
  end

  def set_character
    @data = if side == 'white'
              '♔ '
            else
              '♚ '
            end
  end
end
