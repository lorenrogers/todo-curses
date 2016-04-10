require 'ncursesw'
require 'todo-txt'

# Interactive application for handling todo.txt files
module TodoCurses
  include Todo

  # A curses based todo.txt file viewer
  class View
    include Ncurses

    # Run the ncurses application
    def interact
      loop do
        break unless handle_character_input(Ncurses.getch)
      end
      clean_done_tasks
      close_ncurses
    end

    private

    # Maps methods to character inputs from Ncurses.
    # @return [Boolean] false if application should exit.
    #
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def handle_character_input(c)
      case c
      when 'q'.ord then return false
      when 'j'.ord then scroll_down
      when 'k'.ord then scroll_up
      when 'J'.ord then priority_down
      when 'K'.ord then priority_up
      when 'x'.ord then toggle_item_completion
      when 'n'.ord then new_item
      when 'h'.ord then scroll_home
      when 'l'.ord then scroll_end
      else display_message(c)
      end
      true
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
    end

    # Displays a message saying that the character was not recognized.
    def display_message(c)
      @screen.mvprintw(0, 0, "[unknown key `#{Ncurses.keyname(c)}'=#{c}] ")
    end

    # Create a new fileviewer, and view the file.
    def initialize(filename)
      init_curses
      load_file(filename)
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

    # Loads the given file as a todo.txt array. Sets the view to the top
    # and redraws the list view.
    #
    # @param filename [String] path to the text file to be loaded
    def load_file(filename)
      @done_file = File.dirname(filename) + '/done.txt'
      @list = TodoCurses::List.new filename
      @list.sort! { |x, y| y <=> x } # Reverse sort
      items = []
      last_priority = nil
      last_selection = @menu.current_item.user_object if @menu
      current_selection = nil

      # Build the menu item list
      @list.each do |item|
        # Insert dividers on priority change
        if item.priority != last_priority
          divider_priority = item.priority.nil? ? 'N/A' : item.priority.to_s
          divider = Ncurses::Menu::ITEM.new(divider_priority, '')
          items << divider
          last_priority = item.priority
        end

        # Build the todo menu item
        menu_item = Ncurses::Menu::ITEM.new(item.to_s, '') # name, description
        menu_item.user_object = item
        items << menu_item

        # Set the current selection
        current_selection = menu_item if item.to_s == last_selection.to_s
      end

      display_main_menu(items, current_selection)
    end

    # Creates a menu and displays it on the screen.
    #
    # @param items [Array] the items to be shown.
    # @param current_selection [Ncurses::Menu::ITEM] the current menu item.
    def display_main_menu(items, current_selection)
      @menu = build_menu(items)

      # Show the menu
      @screen.clear
      @menu.post_menu

      # Set selection position
      @menu.set_current_item current_selection if current_selection
      @menu.menu_driver(
        Ncurses::Menu::REQ_DOWN_ITEM) if @menu.current_item.user_object.nil?

      # Refresh
      @screen.refresh
    end

    # Builds the main display menu of todo.txt items.
    #
    # @param items [Array] the items to be shown in the list.
    # @return [Ncurses::Menu::MENU] the final menu object to be shown.
    def build_menu(items)
      # Build the final menu object
      menu = Ncurses::Menu::MENU.new items
      menu.set_menu_win(@screen)
      menu.set_menu_sub(@screen.derwin(@screen.getmaxx, @screen.getmaxy, 0, 0))
      menu.set_menu_format(@screen.getmaxy, 1)

      # Set dividers to non-interactive
      menu.menu_items.select { |i| i.user_object.nil? }.each do |divider|
        divider.item_opts_off Ncurses::Menu::O_SELECTABLE
      end
      menu
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

    # Scroll the display up by one line
    # @return [Boolean] true if the action completed successfully.
    def scroll_up
      # Move to the next item if it's not the first in the list
      unless @menu.menu_items[0].user_object.nil? &&
             @menu.current_item.item_index < 2
        result = @menu.menu_driver(Ncurses::Menu::REQ_UP_ITEM)
      end
      # Move to the next item if it's not a divider
      result = @menu.menu_driver(
        Ncurses::Menu::REQ_UP_ITEM) unless @menu.current_item.user_object
      return true if result == Ncurses::Menu::E_OK
      false
    end

    # Scroll the display down by one line
    # @return [Boolean] true if the action completed successfully.
    def scroll_down
      result = @menu.menu_driver(Ncurses::Menu::REQ_DOWN_ITEM)
      result = @menu.menu_driver(
        Ncurses::Menu::REQ_DOWN_ITEM) unless @menu.current_item.user_object
      return true if result == Ncurses::Menu::E_OK
      false
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

    # Collects a new todo item from the user and saves
    # it to the text file.
    def new_item
      field = Ncurses::Form::FIELD.new(1, @screen.getmaxx - 1, 2, 1, 0, 0)
      field.set_field_back(Ncurses::A_UNDERLINE)
      fields = [field]
      my_form = Ncurses::Form::FORM.new(fields)
      my_form.user_object = 'My identifier'

      # Calculate the area required for the form
      rows = []
      cols = []
      my_form.scale_form(rows, cols)

      # Create the window to be associated with the form
      my_form_win = Ncurses::WINDOW.new(rows[0] + 3, cols[0] + 14, 1, 1)
      my_form_win.keypad(TRUE)

      # Set main window and sub window
      my_form.set_form_win(my_form_win)
      my_form.set_form_sub(my_form_win.derwin(rows[0], cols[0], 2, 12))

      my_form.post_form

      # Print field types
      my_form_win.mvaddstr(4, 2, 'New item')
      my_form_win.wrefresh

      # rubocop:disable Style/ColonMethodCall
      # Ncurses seems to require that this is called from the
      # class, rather than the instance.
      Ncurses::stdscr.refresh
      # rubocop:enable Style/ColonMethodCall

      new_item_text = capture_text_field_input(my_form_win, my_form, field)

      # Save results
      save_new_item(new_item_text)

      # Clean up
      my_form.unpost_form
      my_form.free_form

      field.free_field
      # fields.each {|f| f.free_field}
    end

    # Adds a new item to the list and saves the file
    # @param task [String] the task to be added
    # @return [TodoCurses::List] the updated list
    def save_new_item(task)
      @list << TodoCurses::Task.new(task)
      save_list
      @list
    end

    # Saves the current state of the list. Overrides the current file.
    # Reloads the newly saved file.
    def save_list
      File.open(@list.path, 'w') { |file| file << @list.join("\n") }
      load_file @list.path
    end

    # Marks the currently selected menu item as complete and saves the list.
    def toggle_item_completion
      @menu.current_item.user_object.toggle!
      save_list
    end

    # Saves done tasks to done.txt and removes them from todo.txt
    def clean_done_tasks
      done_tasks = @list.select { |task| !task.completed_on.nil? }
      File.open(@done_file, 'a') do |file|
        file << "\n"
        file << done_tasks.join("\n")
      end
      remaining_tasks = @list.select { |task| task.completed_on.nil? }
      File.open(@list.path, 'w') { |file| file << remaining_tasks.join("\n") }
    end

    # put the screen back in its normal state
    def close_ncurses
      Ncurses.echo
      Ncurses.nocbreak
      Ncurses.nl
      Ncurses.endwin
    end

    # Captures text input into a form and returns the resulting string.
    # @param window [Window] the form window
    # @param form [Ncurses::FORM] the form to be captured
    # @param field [Ncurses::FIELD] the form to be captured
    # @return [String] the captured input
    def capture_text_field_input(window, form, field)
      while (ch = window.getch) != 13 # return is ascii 13
        case ch
        when KEY_LEFT then form.form_driver Form::REQ_PREV_CHAR
        when KEY_RIGHT then form.form_driver Form::REQ_NEXT_CHAR
        when KEY_BACKSPACE then form.form_driver Form::REQ_DEL_PREV
        else form.form_driver ch # If it's a normal character, print it
        end
      end
      # Request next to set 0 buffer in field
      form.form_driver Form::REQ_NEXT_FIELD
      Form.field_buffer(field, 0)
    end
  end
end
