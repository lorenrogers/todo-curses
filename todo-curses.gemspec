# Ensure we require the local version and not
# one we might have installed already
require File.join([File.dirname(__FILE__), 'lib', 'todo', 'version.rb'])
# rubocop:disable Lint/UselessAssignment
spec = Gem::Specification.new do |s|
  # rubocop:enable Lint/UselessAssignment
  s.name = 'todo-curses'
  s.version = Todo::VERSION
  s.author = 'Loren Rogers'
  s.email = 'loren@lorentrogers.com'
  s.homepage = 'https://github.com/lorentrogers/todo-curses'
  s.platform = Gem::Platform::RUBY
  s.summary = 'An interactive terminal application for managing todo.txt files.'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc', 'todo.rdoc']
  s.bindir = 'bin'
  s.executables << 'todo-curses'
  s.add_runtime_dependency('gli', '2.13.4')
end
