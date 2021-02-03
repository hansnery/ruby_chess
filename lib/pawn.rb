# frozen_string_literal: true

# :nodoc:
class Pawn
  attr_accessor :longitude, :latitude, :data, :moved_once, :side
  attr_reader :possible_moves, :diagonal_attack

  def initialize(longitude, latitude, side)
    @longitude = longitude
    @latitude = latitude
    @side = side
    @moved_once = false
    set_character
    set_moves
  end

  def set_character
    @data = if side == 'white'
              '♙ '
            else
              '♟ '
            end
  end

  def set_moves
    @possible_moves = if side == 'white'
                        [[0, 2], [0, 1]]
                      else
                        [[0, -2], [0, -1]]
                      end
    @diagonal_attack = if side == 'white'
                         [[-1, 1], [1, 1]]
                       else
                         [[-1, -1], [1, -1]]
                       end
  end

  def jumped?
    @moved_once == true && @possible_moves.size > 1
  end
end
