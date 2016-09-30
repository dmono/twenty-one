# frozen_string_literal: true

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]].freeze       # diagonals

  def initialize
    @squares = {}
    reset
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  # return winning marker or return nil
  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def find_at_risk_square(marker)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      risk_squares = @squares.select do |key, value|
        value.marker == Square::INITIAL_MARKER && line.include?(key)
      end
      if squares.collect(&:marker).count(marker) == 2 &&
         squares.collect(&:marker).count(Square::INITIAL_MARKER) == 1
        return risk_squares.keys.first
      end
    end
    nil
  end

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def marked?
    marker != INITIAL_MARKER
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_accessor :marker, :name, :score

  def initialize
    @marker = ""
    @name = ""
    @score = 0
  end
end

class Computer
  attr_accessor :marker, :name, :score

  def initialize
    @marker = ""
    @name = ""
    @score = 0
  end
end

class TTTGame
  FIRST_TO_MOVE = "choose" # 'human', 'computer', or 'choose'
  WIN_SCORE = 5
  COMPUTER_NAMES = %w(Jon Arya Sansa Robb Ned Caitlyn Bran
                      Daenerys Rickon).freeze

  attr_reader :board, :human, :computer, :human_score, :computer_score,
              :exit_round

  def initialize
    @board = Board.new
    @human = Player.new
    @computer = Computer.new
    @first_player = nil
    @current_marker = nil
    @exit_round = false
  end

  def play
    clear
    display_welcome_message
    set_human_name

    loop do
      set_computer_name
      display_names
      pick_marker
      set_computer_marker
      set_first_player
      set_current_marker

      loop do
        display_board

        loop do
          current_player_moves
          break if board.someone_won? || board.full?
          clear_screen_and_display_board if human_turn?
        end

        update_score
        display_result
        display_score
        break if game_winner?
        break unless start_next_round?
        reset
        display_new_round_message
      end
      break if exit_round
      break unless play_again?
      reset
      score_reset
      display_play_again_message
    end

    display_goodbye_message
  end

  private

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts "First player to win #{WIN_SCORE} rounds is the winner."
    puts ""
  end

  def set_human_name
    name = nil
    loop do
      puts "Please enter your name:"
      name = gets.chomp
      break if !name.empty?
      puts "Sorry, that is not a valid entry."
    end
    human.name = name
  end

  def set_computer_name
    computer.name = COMPUTER_NAMES.sample
  end

  def display_names
    puts "Hi #{human.name}! Your opponent is #{computer.name}."
    puts ""
  end

  def pick_marker
    marker = nil
    loop do
      puts "Pick your marker: X or O"
      marker = gets.chomp
      break if %w(x o).include?(marker.downcase)
      puts "Sorry, that is not a valid choice."
    end
    human.marker = marker.upcase
  end

  def set_computer_marker
    computer.marker = if human.marker == 'X'
                        'O'
                      else
                        'X'
                      end
  end

  def set_first_player
    if FIRST_TO_MOVE == "human"
      @first_player = human.marker
    elsif FIRST_TO_MOVE == "computer"
      @first_player = computer.marker
    else
      choose_first_player
    end
  end

  def choose_first_player
    first = nil
    loop do
      puts "Choose the first player to move: (y)ou, (c)omputer or (r)andom"
      first = gets.chomp
      break if %(y c r).include?(first)
      puts "Sorry, that's not a valid choice. Enter y, c, or r."
    end

    @first_player = if first == 'y'
                      human.marker
                    elsif first == 'c'
                      computer.marker
                    else
                      [human.marker, computer.marker].sample
                    end
  end

  def set_current_marker
    @current_marker = @first_player
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye #{human.name}!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def human_turn?
    @current_marker == human.marker
  end

  def display_board
    puts "#{human.name} is an #{human.marker}. #{computer.name} is \
an #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def joinor(arr, delimiter=', ', word="or")
    arr[-1] = "#{word} #{arr.last}" if arr.size > 1
    arr.size == 2 ? arr.join(' ') : arr.join(delimiter)
  end

  def human_moves
    puts "Choose a square: #{joinor(board.unmarked_keys)}"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    # Computer offense
    square = board.find_at_risk_square(computer.marker)

    # Computer defense
    square = board.find_at_risk_square(human.marker) unless square

    square = 5 unless square || !board.unmarked_keys.include?(5)

    square = board.unmarked_keys.sample unless square

    board[square] = computer.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won this round!"
    when computer.marker
      puts "#{computer.name} won this round!"
    else
      puts "It's a tie!"
    end

    puts "Congratulations! You won the game!" if human.score == WIN_SCORE
    puts "Sorry, you lost the game!" if computer.score == WIN_SCORE
  end

  def display_score
    puts "#{human.name}'s score: #{human.score} | #{computer.name}'s \
score: #{computer.score}"
    puts ""
  end

  def update_score
    case board.winning_marker
    when human.marker
      human.score += 1
    when computer.marker
      computer.score += 1
    end
  end

  def game_winner?
    human.score == WIN_SCORE || computer.score == WIN_SCORE
  end

  def start_next_round?
    answer = nil
    loop do
      puts "Would you like to start the next round? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n."
    end

    @exit_round = true if answer == 'n'
    answer == 'y'
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n."
    end

    answer == 'y'
  end

  def clear
    system 'clear'
  end

  def reset
    board.reset
    @current_marker = @first_player
    clear
  end

  def score_reset
    human.score = 0
    computer.score = 0
  end

  def display_new_round_message
    puts "Let's start the next round!"
    puts ""
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

game = TTTGame.new
game.play
