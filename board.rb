# contains the board dimensions,
# piece locations and provides
# an interface to acess data 
# regarding placing and validating
# pieces
class Board
  def initialize side_length
    @side_length = side_length
    @board = []
    side_length.times do
      @board << []
    end
    @board_history = []
    @stone_colors = [:black, :white]
  end
    
  # prints the board to the screen
  def draw
    width = side_length
    height = side_length
    # print the column names
    print ' '
    c = 'A'
    width.times do
      print "#{c}   "
      c.next!
    end
    print "\n"
    
    # print the top row of the board
    print "1#{color_to_char board[0][0]}"
    (width - 1).times do |x|
      print "---#{color_to_char board[0][x + 1]}"
    end
    print "\n"
    
    # print the other rows
    (height - 1).times do |y|
      # print the vertical lines for the grid
      print " |"
      (width - 1).times { print "   |" }
      print "\n"
      
      # print a row
      print "#{y+2}#{color_to_char board[y + 1][0]}"
      (width - 1).times do |x|
        print "---#{color_to_char board[y + 1][x + 1]}"
      end
      print "\n"
    end
  end
    
  # places a stone, updates the board, returns
  # true if the placement was a success and
  # false if the move is invalid
  def place_and_check row_num, column_letter, color
    if !validate(row_num, column_letter, color)
      return false
    end
    
    board_history << board.collect { |row| row.clone }
    place_stone row_num, column_letter, color
    other_color = stone_colors.find{ |c| color != c }
    update other_color
    puts @board[2][2]
    update color
    
    return true
  end

  def remove_dead_stones
    # record the empty spots
    empty_spots = []
    board.each_with_index do |row, row_num|
      row.each_with_index do |spot, column_num|
        empty_spots << [row_num, column_num] if board[row_num][column_num].nil?
      end
    end

    # if stones can be removed by placing a single stone
    # than that group is dead
    empty_spots.each do |coord_pair|
      @board[coord_pair[0]][coord_pair[1]] = stone_colors[0]
      update stone_colors[1]
      @board[coord_pair[0]][coord_pair[1]] = stone_colors[1]
      update stone_colors[0]
      @board[coord_pair[0]][coord_pair[1]] = nil
    end
  end

  def count_occurrences color
    count = 0
    board.each do |row|
      row.each do |spot|
        count += 1 if spot == color
      end
    end

    count
  end

  # counts the amount of territory that a
  # color controls (skips contested territory)
  def count_territory color
    territory = 0
    side_length.times do |row_num|
      side_length.times do |column_num|
        visited = @board.clone.collect { [] }
        territory += 1 if territory?(color, row_num, column_num, visited)
      end
    end

    territory
  end

  def territory? color, row_num, column_num, visited
    # offsets for adjacent spots
    adjacent_spots = [[0,-1],[0,1],[-1,0],[1,0]]
    
    # looking at it so this spot is visited
    visited[row_num][column_num] = true

    # if the spot has a stone it isnt territory
    return false if board[row_num][column_num]

    # go through the adjacent spots
    adjacent_spots.each do |adjacent_spot|
      # dont check above if at the top
      next if row_num + adjacent_spot[0] < 0 
      # dont check below if at the bottom
      next if row_num + adjacent_spot[0] >= side_length

      # dont check to the left if at the left
      next if column_num + adjacent_spot[1] < 0
      # dont check to the right if at the right
      next if column_num + adjacent_spot[1] >= side_length
      
      # dont check if the adjacent spot hasnt been visited
      next if visited[row_num + adjacent_spot[0]][column_num + adjacent_spot[1]]
      
      # if there's a stone on the adjacent spot
      if board[row_num + adjacent_spot[0]][column_num + adjacent_spot[1]] 
        # not territory unless the stone matches the color
        if board[row_num + adjacent_spot[0]][column_num + adjacent_spot[1]] != color
          return false
        end
      # the adjacent spot is empty
      else
        # return false if it isnt territory
        if !territory?(color, row_num + adjacent_spot[0], column_num + adjacent_spot[1], visited)
          return false
        end
      end
      
    end

    return true
  end
    
  private

  attr_accessor :board, :side_length, :board_history, :stone_colors
    
  # returns true if a move is valid
  # false if it isn't
  def validate row_num, column_letter, color
    # can't place on a spot that has a stone already
    column_num = column_letter.downcase.ord - 'a'.ord
    row_num = row_num.to_i
    if board[row_num - 1][column_num]
      return false
    end
    
    # remember the state before the attempted stone placement
    @board_history << @board.collect { |row| row.clone }
    
    # place the stone and update the board
    place_stone row_num.to_s, column_letter, color
    other_color = stone_colors.find{ |c| color != c }
    update other_color
    update color

    # valid if this board state hasn't been encountered before
    is_valid = !@board_history.include?(@board)

    # restore the board
    @board = board_history.last
    board_history.pop

    return is_valid
  end
    
  # places a stone (does not check validity or error)
  def place_stone row_num, column_letter, color
    column_num = column_letter.downcase.ord - 'a'.ord
    @board[row_num.to_i - 1][column_num] = color
  end
    
  # removes stones as neccessary from the board
  def update color
    # mark all the stones that are dead
    dead_stones = []
    board.length.times { dead_stones << [] }
    board.each_with_index do |row, row_num|
      row.each_with_index do |the_color, column_num|
        dead_stones[row_num][column_num] = (the_color == color and dead?(row_num, column_num))
        
      end
    end

    
    
    # remove the dead stones from the board
    dead_stones.each_with_index do |row, row_num|
      row.each_with_index do |is_dead, column_num|
        if is_dead
          @board[row_num][column_num] = nil
        end
      end
    end
  end
    
  # converts a color or empty spot to a char
  # for printing to screen
  def color_to_char sym
    if sym == :black
      'O'
    elsif sym == :white
      '@'
    else
      '+'
    end
  end
    
  # if the specific stone is free return true
  # otherwise return false
  def free? row, column
    adjacent_spots = [[-1,0],[1,0],[0,-1],[0,1]]

    # load into array to ease iteration
    coords = [row, column]

    # iterate through the pairs of adjacent spot relative coords
    adjacent_spots.each do |adjacent_spot|
      # get the enum to iterate for the absolute coords
      rel_enum = adjacent_spot.each
      # origin + relative = absolute
      abs_coords = coords.collect { |coord| coord + rel_enum.next }

      skip = false
      
      # check the bounds for the absolute coord
      abs_coords.each do |abs_coord|
        skip = true if abs_coord < 0 or abs_coord >= side_length
      end

      next if skip

      # if the absolute spot is empty the stone is free
      return true if board[abs_coords[0]][abs_coords[1]].nil?
    end

    # no free spots
    return false
  end
    
  # return true if the stone is dead
  # else return false
  def dead? row, column, valid_map = board.clone.collect { [] }
    valid_map[row][column] = true
    
    # if this stone has a freedom it isnt dead
    if free? row, column
      return false
    end

    adjacent_spots = [[-1,0],[1,0],[0,-1],[0,1]]

    # load into array to ease iteration
    coords = [row, column]

    # iterate through the pairs of adjacent spot relative coords
    adjacent_spots.each do |adjacent_spot|
      # get the enum to iterate for the absolute coords
      rel_enum = adjacent_spot.each
      # origin + relative = absolute
      abs_coords = coords.collect { |coord| coord + rel_enum.next }

      skip = false
      # check the bounds for the absolute coord
      abs_coords.each do |abs_coord|
        skip = true if abs_coord < 0 or abs_coord >= side_length
      end

      next if skip

      # if the absolute spot is the same color and
      # it isnt a spot thats  been checked before and
      # it isnt dead
      # then this stone isnt dead
      if board[abs_coords[0]][abs_coords[1]] == board[row][column] and
         !valid_map[abs_coords[0]][abs_coords[1]] and
         !dead?(abs_coords[0], abs_coords[1], valid_map)
        return false
      end
    end
  end
end