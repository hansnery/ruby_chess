# frozen_string_literal: true

# :nodoc:
class Tile
  attr_accessor :data, :visited, :parent, :children, :longitude, :latitude

  def initialize
    @data = '  '
    @visited = false
    @parent = nil
    @children = []
    @longitude = nil
    @latitude = nil
  end
end
