# Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

class Test::Builder::Plan {
    has Int $.expected is rw;

    submethod BUILD(:$.expected = 0) {
        die 'Invalid or missing plan!' unless $.expected.defined;
    }

    method header() returns Str {
        return "1..$.expected";
    }

    method footer(Int $ran) returns Str {
        return '' if $ran == $.expected;
        return "Expected $.expected but ran $ran";
    }
}

# vim: ft=perl6

