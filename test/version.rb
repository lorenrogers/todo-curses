require 'test/unit'
require 'todo_curses/version'

class TestVersion < Test::Unit::TestCase
  def test_version
    assert TodoCurses::VERSION
  end
end
