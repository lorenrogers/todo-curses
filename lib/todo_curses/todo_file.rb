require 'todo-txt'

module TodoCurses
  include Todo

  class TodoFile

    attr_accessor :list

    def initialize(filename)
      load_file(filename)
    end

    # Loads the given file as a todo.txt array. Sets the view to the top
    # and redraws the list view.
    #
    # @param filename [String] path to the text file to be loaded
    # @return [TodoCurses::List] the loaded list from the file
    def load_file(filename)
      @done_file = File.dirname(filename) + '/done.txt'
      @list = TodoCurses::List.new filename
      @list.sort! { |x, y| y <=> x } # Reverse sort
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
    def save_list
      File.open(@list.path, 'w') { |file| file << @list.join("\n") }
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
  end
end
