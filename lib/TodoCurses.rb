require 'TodoCurses/list.rb'
require 'TodoCurses/logger.rb'
require 'TodoCurses/view.rb'
require 'TodoCurses/version.rb'
require 'TodoCurses/task.rb'

module TodoCurses
  include Logger

  if ARGV.size != 1
    printf("usage: #{$PROGRAM_NAME} file\n")
    exit
  end

  View.new ARGV[0]
end
