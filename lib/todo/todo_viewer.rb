# A curses based todo.txt file viewer
class TodoViewer

  # Run the ncurses application
  def interact
    while true
      result = true
      c = Ncurses.getch
      case c
      when 'x'.ord
        do_item
      when 'n'.ord
        new_item
      when 'j'.ord
        result = scroll_down
      when 'k'.ord
        result = scroll_up
      when '\s'.ord # white space
        for i in 0..(@screen.getmaxy - 2)
          if( ! scroll_down )
            if( i == 0 )
              result = false
            end
            break
          end
        end
      when Ncurses::KEY_PPAGE
        for i in 0..(@screen.getmaxy - 2)
          if( ! scroll_up )
            if( i == 0 )
              result = false
            end
            break
          end
        end
      when 'h'.ord
        while( scroll_up )
        end
      when 'l'.ord
        while( scroll_down )
        end
      when 'q'.ord
        break
      else
        @screen.mvprintw(0,0, "[unknown key `#{Ncurses.keyname(c)}'=#{c}] ")
      end
      if( !result )
        Ncurses.beep
      end
    end

    clean_done_tasks
    close_ncurses
  end

  private

  # Create a new fileviewer, and view the file.
  def initialize(filename)
    init_curses
    load_file(filename)
    interact
    # TODO: Save a copy of the todo.txt list to backup file.
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
  # @param filename [String] path to the text file to be loaded
  def load_file(filename)
    @done_file = File.dirname(filename) + '/done.txt'
    @list = Todo::List.new filename
    @list.sort! { |x,y| y <=> x } # Reverse sort
    items = []
    @list.each do |item|
      menu_item = Ncurses::Menu::ITEM.new(item.to_s, '') # name, description
      menu_item.user_object = item
      items << menu_item
    end
    @menu = Ncurses::Menu::MENU.new items
    @menu.set_menu_win(@screen)
    @menu.set_menu_sub(@screen.derwin(@screen.getmaxx, @screen.getmaxy, 0, 0))
    @menu.set_menu_format(@screen.getmaxy, 1)
    @menu.post_menu
    @screen.refresh
  end

  # Scroll the display up by one line
  def scroll_up
    @menu.menu_driver(Ncurses::Menu::REQ_UP_ITEM)
  end

  # Scroll the display down by one line
  def scroll_down
    @menu.menu_driver(Ncurses::Menu::REQ_DOWN_ITEM)
  end

  # Collects a new todo item from the user and saves
  # it to the text file.
  def new_item
    field = FIELD.new(1, @screen.getmaxx-1, 2, 1, 0, 0)
    field.set_field_back(A_UNDERLINE)
    fields = [field]
    my_form = FORM.new(fields);
    my_form.user_object = "My identifier"

    # Calculate the area required for the form
    rows = Array.new()
    cols = Array.new()
    my_form.scale_form(rows, cols);

    # Create the window to be associated with the form
    my_form_win = WINDOW.new(rows[0] + 3, cols[0] + 14, 1, 1);
    my_form_win.keypad(TRUE);

    # Set main window and sub window
    my_form.set_form_win(my_form_win);
    my_form.set_form_sub(my_form_win.derwin(rows[0], cols[0], 2, 12));

    my_form.post_form();

    # Print field types
    my_form_win.mvaddstr(4, 2, "New item")
    my_form_win.wrefresh();

    stdscr.refresh();

    new_item_text = capture_text_field_input(my_form_win, my_form, field)

    # Save results
    save_new_item(new_item_text)

    # Clean up
    my_form.unpost_form
    my_form.free_form

    field.free_field
    # fields.each {|f| f.free_field()}
  end

  # Adds a new item to the list and saves the file
  # @param task [String] the task to be added
  # @return [Todo::List] the updated list
  def save_new_item(task)
    @list << Todo::Task.new(task)
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
  def do_item
    item = @menu.current_item
    task = item.user_object
    task.do!
    save_list
  end

  # Saves done tasks to done.txt and removes them from todo.txt
  def clean_done_tasks
    done_tasks = @list.select { |task| !task.completed_on.nil? }
    File.open(@done_file, 'a') { |file| file << done_tasks.join("\n") }
  end

  # put the screen back in its normal state
  def close_ncurses
    Ncurses.echo()
    Ncurses.nocbreak()
    Ncurses.nl()
    Ncurses.endwin()
  end

  # Captures text input into a form and returns the resulting string.
  # @param window [Window] the form window
  # @param form [FORM] the form to be captured
  # @param field [FIELD] the form to be captured
  # @return [String] the captured input
  def capture_text_field_input(window, form, field)
    # Capture typing...
    while((ch = window.getch()) != 13) # return is ascii 13
      case ch
      when KEY_LEFT
        form.form_driver(REQ_PREV_CHAR);
      when KEY_RIGHT
        form.form_driver(REQ_NEXT_CHAR);
      when KEY_BACKSPACE
        form.form_driver(REQ_DEL_PREV);
      else
        # If this is a normal character, it gets Printed
        form.form_driver(ch);
      end
    end
    form.form_driver REQ_NEXT_FIELD # Request next to set 0 buffer in field
    Ncurses::Form.field_buffer(field, 0)
  end
end
