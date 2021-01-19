# frozen_string_literal: true

# :nodoc:
class Tile
  attr_accessor :data, :selected, :longitude, :latitude

  def initialize
    @data = '  '
    @selected = false
    @longitude = nil
    @latitude = nil
  end
end
