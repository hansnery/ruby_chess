# frozen_string_literal: true

# :nodoc:
class Knight
  attr_accessor :longitude, :latitude
  attr_reader :data, :possible_moves

  def initialize(longitude, latitude, side)
    @longitude = longitude
    @latitude = latitude
    @data = if side == 'white'
              '♘ '
            else
              '♞ '
            end
    @possible_moves = [[1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1], [-1, 2]]
  end
end
