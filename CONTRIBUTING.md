# Contributing

This is a great project for brushing up on basic Ruby skills,
and practicing some low-level C-ish Curses along the way.

If you're interested in contributing, please have a look at the
roadmap in the project management folder.
(Alternatively, you could just run `rake roadmap`, which should
open the roadmap in TodoCurses. Very meta.)
There are a lot of interesting features to build out --
pull requests welcome!

Please send a message to me on Github or
[log an issue for your feature][bugtracker] so that there's no
duplicate effort on features.

## Setup

To get started, fork the repo, have a look around, and run the
standard `bundle` to install dependencies.

Next, try building the gem:

    gem build todo-curses.gemspec

This should succeed.

To install this as an actual gem onto your local machine,
run `bundle exec rake install`.

## Developing

To make life a little easier, there are some handy Rake tasks.
`rake run` is the most straight-forward. Assuming you have access
to `/tmp`, and you've already run `bundle`, this should open up
the app. (If not, please [report a bug][bugtracker].)

## Submitting

Once it looks good, write up a [good commit message][commit].
Push to your fork and submit a pull request. Be sure to mention
the issue number you were working on in the bug tracker so that
they're linked up.

[bugtracker]: https://github.com/lorentrogers/todo-curses/issues
[commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html

