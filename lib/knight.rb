# frozen_string_literal: true

# :nodoc:
class Knight
  attr_accessor :longitude, :latitude, :data, :side
  attr_reader :possible_moves

  def initialize(longitude, latitude, side)
    @longitude = longitude
    @latitude = latitude
    @data = if side == 'white'
              '♘ '
            else
              '♞ '
            end
    @possible_moves = [[0, 2], [0, 1]]
    @side = side
  end
end
