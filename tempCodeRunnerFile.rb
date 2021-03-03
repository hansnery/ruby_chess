def ask_input
  #   @board.print_board
  #   if @moving == false
  #     print_select_piece
  #   else
  #     print_move_to
  #   end
  #   input = gets.chomp
  #   @target_longitude = letter_to_longitude(input[0])
  #   @target_latitude = input[1].to_i
  #   check_input(input)
  # end

  # def check_input(input)
  #   case input
  #   when 'save'
  #     savegame
  #   when 'load'
  #     load_savegame
  #   when /^[a-hA-H]{1}[1-8]$/
  #     play_round(input)
  #   else
  #     try_again('wrong_input')
  #   end
  # end