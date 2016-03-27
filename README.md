# TODO-Curses

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

    alias tt#"todo-curses list \~/dev/todo/todo.txt"

## Current features

- Open todo.txt files and view a scrollable list of items
- Move to the next item with `j`
- Move to the prev item with `k`
- Create new items with `n`
- Toggle done / not done state with `x`
- Move priority down with `shift+j`
- Move priority up with `shift+k`
- Completed tasks are archived to done.txt on exit

## Planned features

- Safer file handling (confirmations, errors, etc.)
- Use ctrl instead of shift for priority change
- Color code priorities
- Add a spacer between priority groups
- Priority view with `ctrl+1`
- Project view with `ctrl+2`
- Strip out application wrapper; not needed
- Prep for release as a gem
- If no argument is given, open the default file. Default tbd.

## Ideas for later

- Shift+J: Cycle through displays (Priority, project, etc.)
- F: filter tasks (free-text, one filter condition per line)
- T: append text to selected tasks
- O or Ctrl+O: open todo.txt file
- C or Ctrl+N: new todo.txt file

## Things not included

- A: archive tasks
- Ctrl+C: copy task to clipboard
- Ctrl+Shift+C: copy task to edit field
- Win+Alt+T: hide/unhide windows
- 0: clear filter
- 1-9: apply numbered filter preset

## Keyboard shortcut ideas

- N: new task
- J: next task
- K: prev task
- X: toggle task completion
- D or Del or Backspace: delete task (with confirmation)
- E or F2: update task
- I: set priority
- . or F5: reload tasks from file
- ?: show help
- Shift+K: increase priority
- Shift+J: decrease priority
- Alt+Left/Right: clear priority
- Ctrl+Alt+Up: increase due date by 1 day
- Ctrl+Alt+Down: decrease due date by 1 day
- Ctrl+Alt+Left/Right: remove due date

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
