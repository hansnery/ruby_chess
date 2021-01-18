# frozen_string_literal: true

# :nodoc:
class Knight
  attr_accessor :longitude, :latitude
  attr_reader :data, :possible_moves

  def initialize(longitude, latitude)
    @longitude = longitude
    @latitude = latitude
    @data = '♘ '
    @possible_moves = [[1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1], [-1, 2]]
  end
end
