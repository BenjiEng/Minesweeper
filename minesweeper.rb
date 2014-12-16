require 'yaml'
require 'colorize'
require 'io/console'

class Tile
  attr_accessor :bombed, :coordinates, :flagged, :display_number,
  :revealed

  def initialize(bombed, coordinates)
    @bombed = bombed
    @coordinates = coordinates
    @flagged = false
    @revealed = false
    @display_number = false
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
    valid_neighbors = neighbor_coordinates.select { |x, y| x >= 0 && x <= 8 && y >= 0 && y <= 8 }
    neighbor_tiles = valid_neighbors.map { |x, y| board.grid[x][y] }
  end

  def direct_neighbors(board)
    neighbor_coordinates = [
      [coordinates[0], coordinates[1] + 1],
      [coordinates[0], coordinates[1] -1],
      [coordinates[0] + 1, coordinates[1]],
      [coordinates[0] - 1, coordinates[1]]
    ]
    valid_neighbors = neighbor_coordinates.select { |x, y| x >= 0 && x <= 8 && y >= 0 && y <= 8 }
    neighbor_tiles = valid_neighbors.map { |x, y| board.grid[x][y] }
  end

  def neighbors_bomb_count(board)
    neighbor_tiles = neighbors(board)
    bombed_neighbors = neighbor_tiles.select { |tile| tile.bombed? }
    bombed_neighbors.count
  end

end

class Board
  attr_accessor :grid, :num_bombs

  def initialize
    @grid = Array.new(9) { Array.new(9) }
    @num_bombs = 0
  end

  def set_board
    (0..8).each do |i|
      (0..8).each do |j|

        @grid[i][j] = Tile.new(bomb_or_empty, [i,j])
      end
    end
  end

  def bomb_or_empty
    if rand(5) == 0
      @num_bombs += 1
      true
    else
      false
    end
  end

  def display
    system("clear")
    grid.each do |line|
      line.each do |tile|
        if tile.display_number == true
          print tile.neighbors_bomb_count(self)
          print " ".blink
        elsif tile.display_number == false && tile.revealed == true
          print " ".colorize(:background => :light_white)
          print " "
        elsif tile.flagged? == true
          print "F".colorize(:background => :green)
          print " "
        else
          print " ".colorize(:background => :black)
          print " "
        end
      end
      puts ""
      puts "".underline
    end
  end

  def cursor_location(x, y)
    system("clear")
    grid.each do |line|
      line.each do |tile|
        if tile.display_number == true
          if tile.coordinates == [x, y]
            print "#{tile.neighbors_bomb_count(self)}".colorize(:background => :blue)
          else
            print "#{tile.neighbors_bomb_count(self)}"
          end
          print " "
        elsif tile.display_number == false && tile.revealed == true
          if tile.coordinates == [x, y]
            print " ".colorize(:background => :blue)
          else
            print " ".colorize(:background => :light_white)
          end
          print " "
        elsif tile.flagged? == true
          if tile.coordinates == [x, y]
            print "F".colorize(:background => :blue)
          else
            print "F".colorize(:background => :green)
          end
          print " "
        else
          if tile.coordinates == [x, y]
            print " ".colorize(:background => :blue)
          else
            print " ".colorize(:background => :black)
          end
          print " "
        end
      end
      puts ""
      puts "".underline
    end
  end

  def over?(selected_tile)
    if selected_tile.bombed?
      puts "Boom!"
      exit
    else
      grid.each do |line|
        line.each do |tile|
          if tile.revealed == false && tile.bombed? == false
            return false
          end
        end
      end
    end

    true
  end
end

class Game
  attr_accessor :board

  def initialize
    @board = Board.new
  end

  def new_or_load

    puts "Do you want to start a new game or loud an old one (n or l)?"
    response = gets.chomp

    if response == "n"
      @board.set_board
    else
      puts "What is your save file called?"
      save_file = gets.chomp
      save_file = File.open("#{save_file}.yml")
      @board = YAML::load(save_file)
    end
  end

  def play
    new_or_load

    puts "#{board.num_bombs} bombs on the field."
    while true
      board.display

      x, y = choose_coordinate

      action_choice = action
      if action_choice == "s"
        save
      elsif action_choice == "f"
        update_flag(x, y)
      elsif action_choice == "r"
        if board.over?(board.grid[x][y])
          print "You win!"
        else
          reveal(board.grid[x][y])
        end
      end
    end

  end

  def save
    puts "What would you like to name your save file?"
    filename = gets.chomp
    save_file = File.open("#{filename}.yml", "w")
    save_file.puts board.to_yaml
    save_file.close
    exit
  end

  def reveal(current_tile)
    return if current_tile.revealed == true

    if current_tile.bombed? == false
      current_tile.revealed = true
      current_tile.direct_neighbors(board).each do |neighbor_tile|
        reveal(neighbor_tile)
        if current_tile.neighbors_bomb_count(board) > 0
          current_tile.display_number = true
        end
      end
    end
  end

  def update_flag(x, y)
    if board.grid[x][y].flagged? == true
      board.grid[x][y].flagged = false
    else
      board.grid[x][y].flagged = true
    end
  end

  def action
    print "Please enter flag, reaveal, or save (f, r, s): "
    gets.chomp
  end

  def choose_coordinate
    x = 0
    y = 0
    while true
      case STDIN.getch
      when "\r"
        break
      when "a"
        y -= 1
      when "w"
        x += -1
      when "s"
        x += 1
      when "d"
        y += 1
      end
      @board.cursor_location(x, y)
    end
    [x, y]
  end

end

new_board = Board.new

new_game = Game.new
new_game.play
