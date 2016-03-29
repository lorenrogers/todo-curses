require 'rubocop/rake_task'

# Run the test application
desc 'run'
task :run do
  sh 'bundle exec bin/todo-curses list todo.txt'
end

# Reset the testing todo.txt file, if you have one.
desc 'reset'
task :reset do
  sh 'cp todo.txt.bak todo.txt'
end

# Easy way to rubocop the project
desc 'Lint Ruby'
RuboCop::RakeTask.new(:rubocop) do |t|
  t.patterns = ['bin/**/*.rb', 'lib/**/*.rb']
end

task default: :run
