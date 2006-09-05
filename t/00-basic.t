#!/usr/bin/env perl
use warnings;
use strict;

use Test::More tests => 6;

use_ok('Class::Component::Recipe');

{   my $ccr = Class::Component::Recipe->new;
    ok($ccr, 'creation');
    ok($ccr->get_collection, 'default collection');
}

{   my $ccr = Class::Component::Recipe->new(
        collection_class => 'TestCollection' );
    ok($ccr, 'creation with own collection');
    ok($ccr->get_collection, 'collection exists');
    is($ccr->get_collection->foo, 23, 'own collection extends');
}





package TestCollection;
use warnings;
use strict;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

extends 'Class::Component::Recipe::Collection';

sub foo { 23 }

1;
