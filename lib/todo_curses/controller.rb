require 'todo_curses/todo_file'
require 'todo_curses/view'

# Interactive application for handling todo.txt files
module TodoCurses
  # A curses based todo.txt file viewer
  class Controller
    include Ncurses

    private

    # Create a new fileviewer, and view the file.
    def initialize(filename)
      init_curses
      @file = TodoFile.new(filename)
      @view = View.new(@file, @screen)
      interact
    end

    # Perform the curses setup
    def init_curses
      @screen = Ncurses.initscr
      Ncurses.nonl
      Ncurses.cbreak
      Ncurses.noecho
      @screen.scrollok(true)
    end

    # put the screen back in its normal state
    def close_ncurses
      Ncurses.echo
      Ncurses.nocbreak
      Ncurses.nl
      Ncurses.endwin
    end

    # Run the ncurses application
    def interact
      loop do
        break unless handle_character_input(Ncurses.getch)
      end
      @file.clean_done_tasks # TODO: Break this out into explicit action
      close_ncurses
    end

    # Maps methods to character inputs from Ncurses.
    # @return [Boolean] false if application should exit.
    #
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def handle_character_input(c)
      case c
      when 'q'.ord then return false
      when 'j'.ord then @view.scroll_down
      when 'k'.ord then @view.scroll_up
      when 'J'.ord then priority_down
      when 'K'.ord then priority_up
      when 'x'.ord then toggle_item_completion
      when 'n'.ord then @view.new_item
      when 'h'.ord then scroll_home
      when 'l'.ord then scroll_end
      else display_message(c)
      end
      true
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
    end

    # Toggles completion for the currently selected item in the menu
    def toggle_item_completion
      @view.menu.current_item.user_object.toggle!
    end

    # Scrolls to the top of the list
    def scroll_home
      while scroll_up
      end
    end

    # Scrolls to the end of the list
    def scroll_end
      while scroll_down
      end
    end

    # Moves the current selection's priority up by one unless it is at Z.
    def priority_up
      item = @menu.current_item.user_object
      item.priority_inc!
      save_list
    end

    # Moves the current selection's priority down by one unless it is at A.
    def priority_down
      item = @menu.current_item.user_object
      item.priority_dec!
      save_list
    end
  end
end
