bend
====

Shows the differences that are causing a patch to not apply cleanly

The diff-viewer is currently hardcoded to "meld", but there is a commented line above that lets
you use choose diff instead.
I've been using it with runhaskell ~/bin/bend.hs ./foo.rej
I haven't needed any other cli arguments, so I haven't bothered adding them.