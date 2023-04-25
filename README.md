# whenchanged

Simply run `./whenchanged a b c` and `a b c` will be executed whenever a file
in cwd is written to.

This is the usual quick-and-dirty inotify usage, just written in nim this time.
It covers NONE of the edge cases (yet?), but it was enough for me to put it
in my ~/.local/bin and actually use it, because of how zeroconfig an approach
I needed.
