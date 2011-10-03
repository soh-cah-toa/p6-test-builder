# Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

# TODO Define Test::Builder::Exception
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

C<Test::Builder> is meant to serve as a generic backend for test libraries. Put
differently, it provides the basic "building blocks" and generic functionality
needed for building your own application-specific TAP test libraries.

C<Test::Builder> conforms to the Test Anything Protocol (TAP) specification.

=head1 USE

=head2 Object Initialization

=over 4

=item B<new()>

Returns a new C<Test::Builder> singleton object.

The C<new()> method only returns a new object the first time that it's called.
If called again, it simply returns the same object. This allows multiple
modules to share the global information about the TAP harness's state.

Alternatively, if a singleton object is too limiting, you can use the
C<create()> method instead.

=item B<create()>

# TODO

=back

=head2 Implementing Tests

=over 4

=item plan()

Declares how many tests are going to be run.

If called as C<.plan(*)>, then a plan will not be set. However, it is your job
to call C<.done()> when all tests have been run.

=item ok()

=item nok()

=item todo()

=back

=head1 SEE ALSO

L<http://testanything.org>

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

        # Display verbose report unless test passed
        if $test {
            self!report_test(Test::Builder::Test.new(
                :number(self!get_test_number),
                :passed($test),
                :description($description)));
        }
        else {
            self!report_test(Test::Builder::Test.new(
                    :number(self!get_test_number),
                    :passed($test),
                    :description($description)),
                :verbose({ got => $got, expected => $expected }));
        }

        return $test;
    }

    method isnt(Mu $got, Mu $expected, Str $description= '') {
        my Bool $test = ?$got ne ?$expected;

        # Display verbose report unless test passed
        if $test {
            self!report_test(Test::Builder::Test.new(
                :number(self!get_test_number),
                :passed($test),
                :description($description)));
        }
        else {
            self!report_test(Test::Builder::Test.new(
                    :number(self!get_test_number),
                    :passed($test),
                    :description($description)),
                :verbose({ got => $got, expected => $expected }));
        }

        return $test;
    }

    method todo(Mu $todo, Str $description = '', Str $reason = '') {
        self!report_test(Test::Builder::Test.new(:todo(Bool::True),
                                                 :number(self!get_test_number),
                                                 :reason($reason),
                                                 :description($description)));

        return $todo;
    }

    method !report_test(Test::Builder::Test::Base $test, :%verbose) {
        die 'No plan set!' unless $!plan;

        @!results.push($test);

        $!output.write($test.report);
        $!output.diag($test.verbose_report(%verbose)) if %verbose;
    }

    method !get_test_number() {
        return +@!results + 1;
    }

# vim: ft=perl6

