# Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

class Test::Builder::Output {
    has $!stdout;
    has $!stderr;

    submethod BUILD($!stdout = $*OUT, $!stderr = $*ERR) { ... }

    method write(Str $msg is copy) {
        $msg ~~ s:g/\n <!before \#>/\n \# <space>/;
        $!stdout.say($msg);
    }

    method diag(Str $msg is copy) {
        $msg ~~ s/^ <!before \#>/\# <space>/;
        $msg ~~ s:g/\n <!before \#>/\n \# <space>/;
        $!stderr.say($msg);
    }
}

# vim: ft=perl6

