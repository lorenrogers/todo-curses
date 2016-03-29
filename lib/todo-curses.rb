lib = File.dirname(__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Gems
require 'gli'
require 'ncursesw'

# Lib
require 'todo-curses/list'
require 'todo-curses/logger'
require 'todo-curses/task'
require 'todo-curses/todo_viewer'
require 'todo-curses/version'
