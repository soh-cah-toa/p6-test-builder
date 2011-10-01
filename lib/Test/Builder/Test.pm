# Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

# TODO  Rename Test::Builder::Base to something else
# FIXME This should probably be a class, not a role
# FIXME Refactor Test::Builder::Base inheritance tree

class Test::Builder::Test::Pass does Test::Builder::Test::Base { }
class Test::Builder::Test::Fail does Test::Builder::Test::Base { }

role Test::Builder::Test::Base {
    has Bool $.passed;
    has Int  $.number     = 0;
    has Str  $.diagnostic = '???';
    has Str  $.description;

    method status() returns Hash {
        return {
            passed      => $!passed,
            description => $!description
        };
    }

    method report() returns Str {
        my $result = $!passed ?? 'ok ' !! 'not ok ';

        $result   ~= $!number;
        $result   ~= " - $!description" if $!description;

        return $result;
    }
}

class Test::Builder::Test {
    has $!passed;
    has $!number;
    has $!diag;
    has $!description;

    # XXX Should $passed be of type Bool instead?

    method new(Int :$number,
               Int :$passed      = 1,
               Int :$skip        = 0,
               Int :$todo        = 0,
               Str :$reason      = '',
               Str :$description = '') {

        #return Todo.new(:description($description),
                        #:passed($passed),
                        #:reason($reason),
                        #:number($number)) if $todo;

        #return Skip.new(:description($description),
                        #:passed(1),
                        #:reason($reason),
                        #:number($number)) if $skip;

        return Test::Builder::Test::Pass.new(:description($description),
                                             :passed(1),
                                             :number($number)) if $passed;

        return Test::Builder::Test::Fail.new(:description($description),
                                             :passed(0),
                                             :number($number));
    }

    method report() returns Str {
        my $result = $!passed ?? 'ok ' !! 'not ok ';

        $result   ~= $!number;
        $result   ~= " - $!description" if $!description;

        return $result;
    }
}

# vim: ft=perl6

