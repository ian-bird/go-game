require_relative 'board.rb'

# contains all data and interfaces
# related to running the game
class Game
  # sets up game state from setup info
  def initialize setup_info
    @board = Board.new setup_info[:length]
    @handicap = setup_info[:handicap]
    @current_color = :white
    @stone_colors = [:white, :black]
    @move_history = []
  end
    
  # interacts with the user to get the next move
  def take_next_move
    spot = {}
    input_cleaned = ''
    while input_cleaned.empty?
      puts "enter coordinates of next stone (#{current_color}\'s turn) or ! to pass:"
      input_string = gets.downcase
      input_cleaned = input_string.match(/^[a-z][0-9]$/).to_s
      input_string.chomp!
      input_cleaned = input_string if input_string == '!'
    end
  
    if input_cleaned == '!'
      :pass
    else
      spot[:column] = input_cleaned[0]
      spot[:row] = input_cleaned[1]
      spot
    end
  end
    
  # one player places one stone
  def next_turn
    next_move = take_next_move
    # if the move isn't pass, it needs to be validated, placed,
    # and the board updated
    if next_move != :pass
      valid = board.place_and_check next_move[:row], next_move[:column], current_color
        
      while !valid
        next_move = take_next_move
        break if next_move == :pass
        valid = board.place_and_check next_move[:row], next_move[:column], current_color
      end
    end
    
    move_history << next_move
    
    if handicap <= 0
      @current_color = stone_colors.find{ |c| @current_color != c }
    else
      handicap -= 1
    end
  end
    
  # returns true when the game is over
  def over?
    move_history[-1] == :pass && move_history[-2] == :pass
  end
    
  def score
    board.remove_dead_stones

    # count remaining stones
    scores = {}
    stone_colors.each { |color| scores[color] = board.count_occurrences(color) }

    # count territory
    stone_colors.each { |color| scores[color] += board.count_territory(color) }

    # print scores
    stone_colors.each { |color| puts "#{color} score: #{scores[color]}" }
  end
    
  attr_reader :board
    
  private
  attr_accessor :handicap, :current_color, :stone_colors, :move_history
end