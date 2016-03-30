# TodoCurses

A curses-based application for managing todo.txt files.

![Todo-Curses demo screen capture](
https://raw.githubusercontent.com/lorentrogers/todo-curses/master/images/todo-curses-demo.gif)

A lot of the features are based on how
[todotxt.net](todotxt.net)
handles things. I really liked the overall design of the application,
just not the fact that it didn't run in my linux terminal. To solve
this, I decided to roll my own using Ruby and Ncurses. There was already
a robust library for handling todo.txt files, and Ncurses was something
I'd been meaning to learn for a while.

No doubt there's a ton of nasty code in here. I'm sure there's a lot
that can be refactored; pull requests welcome!

![Gem Version](https://badge.fury.io/rb/todo-curses.svg)

[Gem available on Rubygems.org](https://rubygems.org/gems/todo-curses)

[Source on github.com](https://github.com/lorentrogers/todo-curses)

## Installation

Grab the gem:

    gem install todo-curses

Then you'll probably want to make an alias in your .\*rc file. Here's
mine:

    alias t="todo.sh"
    alias tt="vim ~/dev/todo/todo.txt"
    alias ts="cd ~/dev/todo;./save.sh;cd -;t archive"
    alias ttt="todo-curses ~/dev/todo/todo.txt"

This gives three ways to interact with the todo.txt file, depending
on the task at hand. Because todo-curses is still in the experimental
phase, I use Vim for my day-to-day work.

## Current features

- Open todo.txt files and view a scrollable list of items
- Move to the next item with `j`
- Move to the prev item with `k`
- Create new items with `n`
- Toggle done / not done state with `x`
- Move priority down with `shift+j`
- Move priority up with `shift+k`
- Completed tasks are archived to done.txt on exit

## Development

To release a new version, update
the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem`
file to [rubygems.org](https://rubygems.org).
After checking out the repo, run `bin/setup` to install dependencies.
You can also run `bin/console` for an interactive prompt that
will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## License

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
