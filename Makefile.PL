use inc::Module::Install;
use warnings;
use strict;

name                q(Class-Component-Recipe);
abstract_from       q(lib/Class/Component/Recipe.pm);
version_from        q(lib/Class/Component/Recipe.pm);
author              q(Robert 'phaylon' Sedlacek <phaylon@dunkelheit.at>);
license             q(perl);

requires            @$_ for ( ['Class::Inspector' => 0],
                              ['Carp::Clan'       => 0],
                              ['Moose'            => 0],
                              ['Moose::Policy'    => 0],
                              ['aliased'          => 0] );

build_requires      'Test::More' => 0;

WriteAll;

1;
