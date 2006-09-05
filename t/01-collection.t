#!/usr/bin/env perl
use warnings;
use strict;

use Test::More tests => 24;

use_ok('Class::Component::Recipe');

my $ccr = Class::Component::Recipe->new;
my $col = $ccr->get_collection;

$col->push($_) for qw(Foo1 Foo2 Foo3);
is_deeply($col->get_classes, [qw(Foo1 Foo2 Foo3)], 'pushing classes');

is($col->get_position_of('Foo2'), 1, 'class position correct');

is($col->unshift('Bar'), 1, 'correct unshift rv');
is_deeply($col->get_classes, [qw(Bar Foo1 Foo2 Foo3)], 'unshifting a class');

is($col->pop, 'Foo3', 'popped last item');
is_deeply($col->get_classes, [qw(Bar Foo1 Foo2)], 'popped item removed');

is($col->shift, 'Bar', 'shifted first item');
is_deeply($col->get_classes, [qw(Foo1 Foo2)], 'shifted item removed');

$col->insert('Baz', 1) for 1 .. 3;
is_deeply($col->get_classes, [qw(Foo1 Baz Foo2)], 'inserted class in the middle');

$col->remove($_) for qw(DoesNotExist Foo2);
is_deeply($col->get_classes, [qw(Foo1 Baz)], 'removing existing and non-existing classes');

$col->replace('Foo1', 'FooNew');
is_deeply($col->get_classes, [qw(FooNew Baz)], 'replacing a class in the list');

is($col->push('FooNew'), 0, 'pushing existing without force');
is_deeply($col->get_classes, [qw(FooNew Baz)], 'no change');

is($col->push('FooNew', 1), 1, 'pushing existing with force');
is_deeply($col->get_classes, [qw(Baz FooNew)], 'moved to new position');

is($col->unshift('FooNew'), 0, 'unshifting existing without force');
is_deeply($col->get_classes, [qw(Baz FooNew)], 'no change');

is($col->unshift('FooNew', 1), 1, 'unshifting existing with force');
is_deeply($col->get_classes, [qw(FooNew Baz)], 'moved to new position');

$col->insert('New', 1);
is($col->insert('New', 3), 0, 'inserting existing without force');
is_deeply($col->get_classes, [qw(FooNew New Baz)], 'no change');

is($col->insert('New', 3, 1), 1, 'inserting existing with force');
is_deeply($col->get_classes, [qw(FooNew Baz New)], 'moved to new position');
