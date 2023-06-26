require_relative 'board'
require_relative 'game'

# interact with user to get
# board size info
def length_prompt
  length = 0
  while length <= 0
    puts 'enter board side length (> 0):'
    length = gets.to_i
  end
  
  length
end

# interact with user to get
# handicap info
def handicap_prompt
  handicap_points = -1
  while handicap_points < 0
    puts 'enter handicap (>= 0):'
    handicap_points = gets.to_i
  end
  
  handicap_points
end
    
# gets setup information
# and returns it
def setup
  length = length_prompt
  handicap = handicap_prompt
  {:length => length, :handicap => handicap}
end
    

setup_info = setup
game = Game.new(setup_info)
while(!game.over?)
  puts game.board.draw
  game.next_turn
end

game.score