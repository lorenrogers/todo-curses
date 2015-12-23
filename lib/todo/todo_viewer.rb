# A curses based todo.txt file viewer
class TodoViewer

  # Create a new fileviewer, and view the file.
  def initialize(filename)
    @list = []
    @screen = nil
    @top = nil
    @cursor = nil
    init_curses
    load_file(filename)
    interact
  end

  # Perform the curses setup
  def init_curses
    # signal(SIGINT, finish)

    @screen = Ncurses.initscr
    Ncurses.nonl
    Ncurses.cbreak
    Ncurses.noecho

    @screen.scrollok(true)
    #$screen.keypad(true)
  end

  # Loads the given file as a todo.txt array. Sets the view to the top
  # and redraws the list view.
  # @param filename [String] path to the text file to be loaded
  def load_file(filename)
    @list = Todo::List.new filename
    @top = 0
    @cursor = 0
    redraw_list
  end

  # Redraw the list display
  def redraw_list
    str = @list[@top]
    if(str)
      @screen.clear
      @list.sort!
      @list[@top..@screen.getmaxy-1+@top].each_with_index { |line, idx|
        @screen.mvprintw(idx, 0, line.to_s)
      }
      @screen.refresh
    end
  end

  # Scroll the display up by one line
  def scroll_up
    if( @top > 0 )
      @screen.scrl(-1)
      @top -= 1
      str = @list[@top].to_s
      if( str )
        @screen.mvprintw(0, 0, str)
      end
      return true
    else
      return false
    end
  end

  # Scroll the display down by one line
  def scroll_down
    if( @top + @screen.getmaxy < @list.length )
      @screen.scrl(1)
      @top += 1
      str = @list[@top + @screen.getmaxy - 1].to_s
      if( str )
        @screen.mvprintw(@screen.getmaxy - 1, 0, str)
      end
      return true
    else
      return false
    end
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
    redraw_list
    save_new_item(new_item_text, @list)
    @screen.mvprintw(0, 0, new_item_text)

    # Clean up
    my_form.unpost_form
    my_form.free_form

    field.free_field
    # fields.each {|f| f.free_field()}
  end

  # Adds a new item to the list and saves the file
  # @param task [String] the task to be added
  # @param list [Todo::List] the task to be added
  # @return [Todo::List] the updated list
  def save_new_item(task, list)
    list << Todo::Task.new(task)
    File.open(list.path, 'w') { |file| file << list.join("\n") }
    list
  end

  # Allow the user to interact with the display.
  # This uses EMACS-like keybindings, and also
  # vi-like keybindings as well, except that left
  # and right move to the beginning and end of the
  # file, respectively.
  def interact
    while true
      result = true
      c = Ncurses.getch
      case c
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

    # put the screen back in its normal state
    Ncurses.echo()
    Ncurses.nocbreak()
    Ncurses.nl()
    Ncurses.endwin()
  end

  private

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
