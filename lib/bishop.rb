# frozen_string_literal: true

# :nodoc:
class Bishop
  attr_accessor :longitude, :latitude
  attr_reader :data, :possible_moves

  def initialize(longitude, latitude, side)
    @longitude = longitude
    @latitude = latitude
    @data = if side == 'white'
              '♗ '
            else
              '♝ '
            end
    # @possible_moves = [[0, 2], [0, 1], [-1, 1], [1, 1]]
  end
end
