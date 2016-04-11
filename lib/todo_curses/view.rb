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
    # rubocop:disable Metrics/CyclomaticComplexity
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
      # rubocop:enable Metrics/CyclomaticComplexity
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

      items = build_menu_item_list(@list)
      display_main_menu(items)
    end

    # Builds the curses menu
    # @return [Array] menu items to be displayed
    def build_menu_item_list(list)
      items = []
      last_priority = nil

      list.each do |item|
        # Insert dividers on priority change
        if item.priority != last_priority
          items << build_priority_divider(item.priority)
          last_priority = item.priority
        end
        items << build_menu_item(item)
      end

      items
    end

    # Creates a new Ncurses menu item for the given object
    #
    # @param item [TodoCurses::Task] the item to be added
    # @return [Ncurses::Menu::ITEM] the new menu item
    def build_menu_item(item)
      menu_item = Ncurses::Menu::ITEM.new(item.to_s, '') # name, description
      menu_item.user_object = item
      menu_item
    end

    # Builds a divider for the menu with the given priority label.
    # If the item has no priority, it uses "N/A" for the label.
    # @param priority [Char] the priority label for the divider to insert
    # @return [Ncurses::Menu::ITEM] the menu item to insert
    def build_priority_divider(priority)
      divider_priority = priority.nil? ? 'N/A' : priority.to_s
      Ncurses::Menu::ITEM.new(divider_priority, '')
    end

    # Creates a menu and displays it on the screen.
    #
    # @param items [Array] the items to be shown.
    def display_main_menu(items)
      current_selection_object = @menu.current_item.user_object if @menu

      @menu = build_menu(items)

      # Show the menu
      @screen.clear
      @menu.post_menu

      # Set selection position
      set_menu_selection_position(items, current_selection_object)

      # Refresh
      @screen.refresh
    end

    # Sets the main menu to the given object's position, if it exists.
    # If the resulting selection is on a divider, it moves to the
    # next item.
    #
    # @param items [Array] the list of menu items
    # @param current_selection_object [Todo::Task] the object of the current
    # selection
    def set_menu_selection_position(items, current_selection_object)
      index = items.index { |x| x.user_object == current_selection_object }
      @menu.set_current_item items[index] if index
      if @menu.current_item.user_object.nil?
        @menu.menu_driver(Ncurses::Menu::REQ_DOWN_ITEM)
      end
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
      fields = [Ncurses::Form::FIELD.new(1, @screen.getmaxx - 1, 2, 1, 0, 0)]
      fields.first.set_field_back(Ncurses::A_UNDERLINE)
      my_form = Ncurses::Form::FORM.new(fields)

      my_form_win = show_new_item_form(my_form)

      # rubocop:disable Style/ColonMethodCall
      # Ncurses seems to require that this is called from the
      # class, rather than the instance.
      Ncurses::stdscr.refresh
      # rubocop:enable Style/ColonMethodCall

      save_new_item(capture_text_field_input(my_form_win,
                                             my_form, fields.first))
      clean_form(my_form, fields)
    end

    # Displays the form in the main window
    #
    # @return [Ncurses::WINDOW] the window showing the new form
    def show_new_item_form(my_form)
      # Calculate the area required for the form
      my_form.scale_form(rows = [], cols = [])

      # Create the window to be associated with the form

      my_form_win = build_form_win(rows, cols)

      # Set main window and sub window
      my_form.set_form_win(my_form_win)
      my_form.set_form_sub(my_form_win.derwin(rows[0], cols[0], 2, 12))
      my_form.post_form

      # Print field types
      my_form_win.mvaddstr(4, 2, 'New item')
      my_form_win.wrefresh

      my_form_win
    end

    # Creates a new input window
    #
    # @param rows [Array] rows to include
    # @param cols [Array] columns to include
    # @return [Ncurses::WINDOW] the new window
    def build_form_win(rows, cols)
      form_win = Ncurses::WINDOW.new(rows[0] + 3, cols[0] + 14, 1, 1)
      form_win.keypad(TRUE)
      form_win
    end

    # Unposts the form and frees memory for the form and fields
    #
    # @param form [Ncurses::FORM] the form to be cleaned
    # @param fields [Array] an array of form fields to be cleared
    def clean_form(form, fields)
      form.unpost_form
      form.free_form
      fields.each(&:free_field)
    end

    # Adds a new item to the list and saves the file
    #
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
      write_done_file(done_tasks)
      remaining_tasks = @list.select { |task| task.completed_on.nil? }
      File.open(@list.path, 'w') { |file| file << remaining_tasks.join("\n") }
    end

    # Writes the given tasks to the done.txt file.
    #
    # @param done_tasks [TodoCurses::Task] the tasks to write to the file
    def write_done_file(done_tasks)
      File.open(@done_file, 'a') do |file|
        file << "\n"
        file << done_tasks.join("\n")
      end
    end

    # put the screen back in its normal state
    def close_ncurses
      Ncurses.echo
      Ncurses.nocbreak
      Ncurses.nl
      Ncurses.endwin
    end

    # Captures text input into a form and returns the resulting string.
    #
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
