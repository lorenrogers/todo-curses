desc 'run'
task :run do
  sh 'bundle exec bin/todo-curses list todo.txt'
end

desc 'reset'
task :reset do
  sh 'cp todo.txt.bak todo.txt'
end

task default: :run
