# Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

class Test::Builder::Output;
    has $!stdout;
    has $!stderr;

    submethod BUILD($!stdout = $*OUT, $!stderr = $*ERR) { ... }

    method write(Str $msg is copy) {
        #$msg ~~ s:g/\n <!before \#>/\n \# <space>/;
        $!stdout.say($msg);
    }

    method diag(Str $msg is copy) {
        # XXX Uncomment lines when Rakudo supports negative lookahead assertions
        #$msg ~~ s/^ <!before \#>/\# <space>/;
        #$msg ~~ s:g/\n <!before \#>/\n \# <space>/;

        $msg ~~ s/^/\x23 \x20/;
        $msg.=subst("\x0a", "\x0a\x23\x20");

        $!stderr.say($msg);
    }

# vim: ft=perl6

