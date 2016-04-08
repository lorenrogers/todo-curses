require 'TodoCurses/view.rb'
require 'TodoCurses/version.rb'
require 'todo-txt'

module TodoCurses
  include Todo

  if ARGV.size != 1
    printf("usage: #{$PROGRAM_NAME} file\n")
    exit
  end

  View.new ARGV[0]
end
