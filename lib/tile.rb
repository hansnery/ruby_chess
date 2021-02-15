# frozen_string_literal: true

# :nodoc:
class Tile
  attr_accessor :data, :longitude, :latitude, :selected, :highlighted, :side

  def initialize
    @data = '  '
    @longitude = nil
    @latitude = nil
    @selected = false
    @highlighted = false
    @side = nil
  end

  def empty?
    @data == '  '
  end

  def not_empty?
    @data != '  '
  end

  def check?
    @data == '♔ ' || @data == '♚ '
  end

  def controlled_by_white?
    @side == 'white'
  end

  def controlled_by_black?
    @side == 'black'
  end
end
