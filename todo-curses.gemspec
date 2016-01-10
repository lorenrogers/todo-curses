# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','todo','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'todo-curses'
  s.version = Todo::VERSION
  s.author = 'Loren Rogers'
  s.email = 'loren@lorentrogers.com'
  s.homepage = 'http://www.lorentrogers.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'An interactive terminal application for managing todo.txt files.'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','todo.rdoc']
  s.rdoc_options << '--title' << 'todo-curses' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'todo-curses'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.13.4')
end
