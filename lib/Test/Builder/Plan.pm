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
        # Determine whether to use past or present tense in message
        my Str $tests = $.expected > 1 ?? 'tests' !! 'test';

        return $ran == $.expected
            ?? ''
            !! "\# Looks like you planned $.expected $tests but ran $ran.";
    }
}

# vim: ft=perl6

