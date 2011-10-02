# Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

# TODO Make Test::Builder a singleton object
# TODO Replace die() with fail()

=begin pod

=head1 NAME

Test::Builder - flexible framework for building TAP test libraries

=head1 SYNOPSIS

=begin code

    my $tb = Test::Builder.new;

    $tb.plan(2);

    $tb.ok(1, 'This is a test');
    $tb.ok(1, 'This is another test');

    $tb.done;

=end code

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item ok()

=item nok()

=item todo()

=back

=head1 ACKNOWLEDGEMENTS

C<Test::Builder> was largely inspired by chromatic's work on the old
C<Test::Builder> module for Pugs.

Additionally, C<Test::Builder> is based on the Perl 5 module of the same name
also written by chromatic <chromatic@wgz.org> and Michael G. Schwern
<schwern@pobox.com>.

=head1 COPYRIGHT

Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

This program is distributed under the terms of the Artistic License 2.0.

For further information, please see LICENSE or visit 
<http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt>.

=end pod

use Test::Builder::Test;
use Test::Builder::Plan;
use Test::Builder::Output;

class Test::Builder:<soh_cah_toa 0.0.1>;
    has Test::Builder::Test       @!results;

    has Test::Builder::Plan::Base $!plan;
    has Test::Builder::Output     $!output handles 'diag';

    submethod BUILD(Test::Builder::Plan   $!plan?,
                    Test::Builder::Output $!output = Test::Builder::Output.new) { }

    # TODO Refactor done() into an END block
    method done() {
        my $footer = $!plan.footer(+@!results);
        $!output.write($footer) if $footer;
    }

    multi method plan(Int $tests) {
        die 'Plan already set!' if $!plan;

        $!plan = Test::Builder::Plan.new(:expected($tests));
    }

    multi method plan(Whatever $tests) {
        die 'Plan already set!' if $!plan;

        $!plan = Test::Builder::NoPlan.new;
    }

    # TODO Implement skip_all and no_plan
    multi method plan(Str $explanation) { ... }

    multi method plan(Any $any) {
        die 'Unknown plan!';
    }

    method ok(Mu $passed, Str $description= '') {
        self!report_test(Test::Builder::Test.new(:number(self!get_test_number),
                                                 :passed(?$passed),
                                                 :description($description)));

        return $passed;
    }

    method nok(Mu $passed, Str $description= '') {
        self!report_test(Test::Builder::Test.new(:number(self!get_test_number),
                                                 :passed(!$passed),
                                                 :description($description)));

        return $passed;
    }

    method is(Mu $got, Mu $expected, Str $description= '') {
        my Bool $test = ?$got eq ?$expected;

        self!report_test(Test::Builder::Test.new(:number(self!get_test_number),
                                                 :passed($test),
                                                 :description($description)));

        return $test;
    }

    method isnt(Mu $got, Mu $expected, Str $description= '') {
        my Bool $test = ?$got ne ?$expected;

        self!report_test(Test::Builder::Test.new(:number(self!get_test_number),
                                                 :passed($test),
                                                 :description($description)));

        return $test;
    }

    method todo(Mu $todo, Str $description = '', Str $reason = '') {
        self!report_test(Test::Builder::Test.new(:todo(Bool::True),
                                                 :number(self!get_test_number),
                                                 :reason($reason),
                                                 :description($description)));

        return $todo;
    }

    method !report_test(Test::Builder::Test::Base $test) {
        die 'No plan set!' unless $!plan;

        @!results.push($test);

        $!output.write($test.report);
    }

    method !get_test_number() {
        return +@!results + 1;
    }

# vim: ft=perl6

