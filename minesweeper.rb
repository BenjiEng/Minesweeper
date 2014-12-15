class Tile
  attr_accessor :bombed, :coordinates, :flagged

  def initialize(bombed, coordinates)
    @bombed = bombed
    @coordinates = coordinates
    @flagged = false
    @revealed = false
  end

  def bombed?
    bombed
  end

  def flagged?
    flagged
  end

  def flag
    flagged = true
  end

  def reveal
    revealed = true
  end

  def neighbors(board)
    neighbor_coordinates = [
    [coordinates[0], coordinates[1] + 1],
    [coordinates[0], coordinates[1] -1],
    [coordinates[0] + 1, coordinates[1] +1],
    [coordinates[0] + 1, coordinates[1] -1],
    [coordinates[0] - 1, coordinates[1] + 1],
    [coordinates[0] - 1, coordinates[-1] -1],
    [coordinates[0] + 1, coordinates[1]],
    [coordinates[0] - 1, coordinates[1]]
    ]
    valid_neighbors = neighbor_coordinates.select { |x, y| x > 0 && x <= 8 && y > 0 && y <= 8 }
    valid_neighbors.map { |x, y| board.grid[x][y] }
  end

end

class Board
  attr_accessor :grid

  def initialize
    @grid = Array.new(9) { Array.new(9) }
    (0..8).each do |i|
      (0..8).each do |j|

        @grid[i][j] = Tile.new(bomb_or_empty, [i,j])
      end
    end
    grid
  end

  def bomb_or_empty
    if rand(2) == 0
      true
    else
      false
    end
  end

  def display
    grid.each do |line|
      line.each do |tile|
        if tile.bombed? == true
          print "B!"
        else
          print "*"
        end
      end
      puts
    end
  end
end

new_board = Board.new
new_board.display
