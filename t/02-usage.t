#!/usr/bin/env perl
use warnings;
use strict;

use Test::More tests => 8;

use_ok('Class::Component::Recipe');

my $ccr = Class::Component::Recipe->new;
$ccr->set_base_class('TestBase');
my $col = $ccr->get_collection;
$col->push('TestFoo1');
$col->push('TestFoo2');
is($ccr->install('TestTarget'), 1, 'install class');
is_deeply(\@TestTarget::ISA, [qw(TestFoo2 TestFoo1 TestBase)],
    'inheritance set up correctly');
is_deeply([TestTarget->foo], [1,2,3], 'chained call');

@SecondTestTarget::ISA = qw(OldB OldA);

is($ccr->install('SecondTestTarget'), 1, 
    'install class with existing @ISA');
is_deeply(\@SecondTestTarget::ISA,
    [qw(TestFoo2 TestFoo1 OldB OldA TestBase)],
    'inheritance includes existing @ISA');

$col->push('TestFoo3');
is($ccr->install('SecondTestTarget'), 1,
    'reinstall class with existing @ISA');
is_deeply(\@SecondTestTarget::ISA,
    [qw(TestFoo3 TestFoo2 TestFoo1 OldB OldA TestBase)],
    'inheritance still includes existing @ISA');

package TestBase;
use Class::C3;
sub foo { return 1 }
package TestFoo1;
use Class::C3;
sub foo { return((shift)->next::method, 2) }
package TestFoo2;
use Class::C3;
sub foo { return((shift)->next::method, 3) }

package OldA; sub noop { }
package OldB; sub noop { }
package TestFoo3; sub noop { }
