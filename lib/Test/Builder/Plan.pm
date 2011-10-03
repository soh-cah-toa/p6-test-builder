# Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

role Test::Builder::Plan::Base {
    method header() returns Str {
        return '';
    }

    method footer(Int $ran) returns Str {
        return "1..$ran";
    }
}

class Test::Builder::Plan does Test::Builder::Plan::Base {
    has Int $.expected is rw;

    submethod BUILD(:$.expected = 0) {
        die 'Invalid or missing plan!' unless $.expected.defined;
    }

    method header() returns Str {
        return "1..$.expected";
    }

    method footer(Int $ran) returns Str {
        # Determine whether to use past or present tense in message
        my Str $s = $.expected == 1 ?? '' !! 's';

        return $ran == $.expected
            ?? ''
            !! "\# Looks like you planned $.expected test$s but ran $ran.";
    }
}

class Test::Builder::NoPlan does Test::Builder::Plan::Base { }

# vim: ft=perl6

