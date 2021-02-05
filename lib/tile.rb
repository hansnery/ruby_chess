# frozen_string_literal: true

# :nodoc:
class Tile
  attr_accessor :data, :longitude, :latitude, :selected, :highlighted, :stop

  def initialize
    @data = '  '
    @longitude = nil
    @latitude = nil
    @selected = false
    @highlighted = false
  end

  def empty?
    @data == '  '
  end

  def not_empty?
    @data != '  '
  end
end
