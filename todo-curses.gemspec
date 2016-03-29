# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'TodoCurses/version'

Gem::Specification.new do |spec|
  spec.name          = "todo-curses"
  spec.license       = "GPL-3.0"
  spec.version       = TodoCurses::VERSION
  spec.authors       = ["Loren Rogers"]
  spec.email         = ["loren@lorentrogers.com"]
  spec.summary       = %q{An interactive terminal application for managing todo.txt files.}
  spec.homepage      = "https://github.com/lorentrogers/todo-curses"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency('rdoc', '~> 4.2', '>= 4.2.2')
  spec.add_development_dependency('aruba', '~> 0.14.1')
  spec.add_dependency('methadone', '~> 1.9', '>= 1.9.2')
  spec.add_dependency('ncursesw', '~> 1.4', '>= 1.4.9')
  spec.add_development_dependency('test-unit', '~> 3.1', '>= 3.1.8')
  spec.add_development_dependency('rubocop', '~> 0.39.0')
end
