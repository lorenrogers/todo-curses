# Contributing

If you find this app useful, please consider contributing to its
development. There are plenty of wish-list features in the
[bug tracker][bugtracker].

To get started, fork the repo, have a look around, and try building
the gem:

    gem build todo-curses.gemspec

This should succeed.

Then, [find an issue][bugtracker] (or log one) and add a comment saying that
you'd like to work on it.
(So that we don't end up with duplicate effort.)

## Developing

To make life a little easier, I've set up some Rake tasks.
If you create a `todo.txt.bak` file, you can run `rake reset`, which
will copy it into `todo.txt`. Then you can run `rake` and it will
open the app on this file.

## Submitting

Once it looks good, write up a [good commit message][commit].
Push to your fork and submit a pull request. Be sure to mention
the issue number you were working on in the bug tracker so that
they're linked up.

[bugtracker]: https://github.com/lorentrogers/jekylljournal/issues
[commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html

