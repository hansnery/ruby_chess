# frozen_string_literal: true

# :nodoc:
# rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize
module Console
  def welcome
    puts "\nWelcome to RubyChess!\n\nIn this program you can play chess using just the command line!"
    puts "\nTo select and move a piece, type in the piece\'s"
    puts 'coordinates using algebraic notation (eg: b3).'
    puts "\nTo save the game, type \'save\'.\nTo load the saved game, type \'load\'."
  end

  def ask_input
    @board.print_board
    if @moving == false
      print_select_piece
    else
      print_move_to
    end
    input = gets.chomp
    @target_longitude = letter_to_longitude(input[0])
    @target_latitude = input[1].to_i
    check_input(input)
  end

  def check_input(input)
    case input
    when 'save'
      savegame
    when 'load'
      load_savegame
    when /^[a-hA-H]{1}[1-8]$/
      play_round(input)
    else
      try_again('wrong_input')
    end
  end

  def try_again(because)
    puts "\nWrong input! Try again!".colorize(color: :yellow) if because == 'wrong_input'
    puts "\nIt\'s white\'s turn!".colorize(color: :yellow) if because == 'whites_turn'
    puts "\nIt\'s black\'s turn!".colorize(color: :yellow) if because == 'blacks_turn'
    puts "\nThis piece can\'t move! Choose another one.".colorize(color: :yellow) if because == 'cant_move'
    puts "\nCan\'t move to the same place!".colorize(color: :yellow) if because == 'cant_move_to_same_place'
    puts "\nKing is still in check! Try another move.".colorize(color: :yellow) if because == 'king_still_in_check'
    new_game? if @checkmate == true
    ask_input
  end

  def piece_cant_move
    clear_board
    try_again('cant_move')
  end

  def display_check_message
    puts "\nCHECK!".colorize(color: :yellow) if @check == true && @checkmate == false
  end

  def savegame
    puts "\nSaving game..."
    savegame = YAML.dump(self)
    File.open('savegame.yaml', 'w') { |save| save.write savegame }
    ask_input
  end

  def load_savegame
    puts "\nLoading game..."
    savegame = File.open('savegame.yaml')
    loaded_game = YAML.safe_load(savegame)
    loaded_game.ask_input
  end

  def print_select_piece
    # puts "\nCheck: #{@check}\nTurn: #{@turn}\n"
    if @turn == 'white'
      puts 'SELECT PIECE(WHITE): '.colorize(color: :yellow)
    else
      puts 'SELECT PIECE(BLACK): '.colorize(color: :yellow)
    end
  end

  def print_move_to
    # puts "\nCheck: #{@check}\nTurn: #{@turn}\n"
    if @turn == 'white'
      puts 'MOVE TO(WHITE): '.colorize(color: :yellow)
    else
      puts 'MOVE TO(BLACK): '.colorize(color: :yellow)
    end
  end

  def change_player
    @turn = 'black' if @selected_piece.side == 'white'
    @turn = 'white' if @selected_piece.side == 'black'
  end

  def check_input_for_new_game(input)
    case input
    when /^(y|n)/
      exit(true) if input == 'n'
      if input == 'y'
        initialize
        clear_board
      end
    else
      try_again('wrong_input')
    end
  end

  def new_game?
    puts "\nWould you like to start a new game? [Y/N]"
    input = gets.chomp.downcase
    check_input_for_new_game(input)
  end
end
# rubocop:enable Metrics/CyclomaticComplexity,Metrics/AbcSize
# EOF
