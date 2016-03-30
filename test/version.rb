require 'test/unit'
require 'TodoCurses/version'

class TestVersion < Test::Unit::TestCase
  def test_version
    assert TodoCurses::VERSION
  end
end
