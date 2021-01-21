# frozen_string_literal: true

# :nodoc:
class Pawn
  attr_accessor :longitude, :latitude, :data, :moved_once, :side
  attr_reader :possible_moves, :diagonal_attack

  def initialize(longitude, latitude, side)
    @longitude = longitude
    @latitude = latitude
    @possible_moves = [[0, 2], [0, 1]]
    @diagonal_attack = [[-1, 1], [1, 1]]
    @moved_once = false
    @side = side
    set_character
  end

  def set_character
    @data = if side == 'white'
              '♙ '
            else
              '♟ '
            end
  end

  def jumped?
    @moved_once == true && @possible_moves.size > 1
  end
end
