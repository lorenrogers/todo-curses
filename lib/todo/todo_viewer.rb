include Ncurses
include Ncurses::Form

# A curses based todo.txt file viewer
class TodoViewer

  # Create a new fileviewer, and view the file.
  def initialize(filename)
    @data_lines = []
    @screen = nil
    @top = nil
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

  # Load the file into memory, and put
  # the first part on the curses display.
  def load_file(filename)
    open(filename, "r") do |fp|
      # slurp the file
      fp.each_line { |l|
        @data_lines.push(l.chop)
      }
    end
    @top = 0
    @data_lines[0..@screen.getmaxy-1].each_with_index{|line, idx|
      @screen.mvprintw(idx, 0, line)
    }
    @screen.refresh
    # rescue
    #   raise "cannot open file '#{filename}' for reading"
  end

  # Redraw the list display
  def redraw_list
    str = @data_lines[@top]
    if( str )
      @screen.clear
      @data_lines[@top..@screen.getmaxy-1+@top].each_with_index{|line, idx|
        @screen.mvprintw(idx, 0, line)
      }
      @screen.refresh
    end
  end

  # Scroll the display up by one line
  def scroll_up
    if( @top > 0 )
      @screen.scrl(-1)
      @top -= 1
      str = @data_lines[@top]
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
    if( @top + @screen.getmaxy < @data_lines.length )
      @screen.scrl(1)
      @top += 1
      str = @data_lines[@top + @screen.getmaxy - 1]
      if( str )
        @screen.mvprintw(@screen.getmaxy - 1, 0, str)
      end
      return true
    else
      return false
    end
  end

  def new_item
    field = FIELD.new(1, 10, 2, 1, 0, 0)
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
    my_form_win.bkgd(Ncurses.COLOR_PAIR(3));
    my_form_win.keypad(TRUE);

    # Set main window and sub window
    my_form.set_form_win(my_form_win);
    my_form.set_form_sub(my_form_win.derwin(rows[0], cols[0], 2, 12));

    my_form.post_form();

    # Print field types
    my_form_win.mvaddstr(4, 2, "No Type")
    my_form_win.wrefresh();

    stdscr.refresh();

    # Capture typing...
    while((ch = my_form_win.getch()) != KEY_F1)
      case ch
      # when KEY_DOWN
      # when KEY_UP
      when KEY_LEFT
        # Go to previous field
        my_form.form_driver(REQ_PREV_CHAR);
      when KEY_RIGHT
        # Go to previous field
        my_form.form_driver(REQ_NEXT_CHAR);
      when KEY_BACKSPACE
        my_form.form_driver(REQ_DEL_PREV);
      else
        # If this is a normal character, it gets Printed
        my_form.form_driver(ch);
      end
    end

    # Print results
    redraw_list
    my_form.form_driver REQ_NEXT_FIELD # Request next to set 0 buffer in field
    @screen.mvprintw(0, 0, Ncurses::Form.field_buffer(field, 0))

    # Clean up
    my_form.unpost_form
    my_form.free_form

    field.free_field
    # fields.each {|f| f.free_field()}
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
end
