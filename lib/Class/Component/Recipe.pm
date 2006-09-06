=head1 NAME

Class::Component::Recipe - Dynamic Component Containers

=cut

package Class::Component::Recipe;
use warnings;
use strict;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

use aliased 'Class::Component::Recipe::Collection';

our $VERSION = '0.01_02';

=head1 SYNOPSIS

  use Class::Component::Recipe;

  # Create a new C:C:R object. Most work is done in the collection
  my $ccr = Class::Component::Recipe->new(base_class => 'Foo::Base');
  my $col = $ccr->get_collection;

  # Prepare the class list as you need it. See the Collection pod.
  $col->push('Foo::ComponentA');
  $col->push('Foo::ComponentB');
  $col->insert('Foo::Middle', 1);

  # Install. @MyApp::Foo::ISA is now: Foo::ComponentB, Foo::Middle,
  # Foo::ComponentA, Foo::Base. Previously existing entries will be
  # before Foo::Base.
  $ccr->install('MyApp::Foo');

=head1 DESCRIPTION

This module provides functionality to build a collection of classes
and install it together with a base in a container class. This
allows the dynamic creation of component based classes.

=head1 ATTRIBUTES

=head2 (get_|set_|has_)base_class

The base class of the component container to build.

=cut

has 'base_class',
    is => 'rw', isa => 'Str', predicate => 'has_base_class',
    ;

=head2 (get_|set_|has_)collection

The collection object handling component order and installing the
final container.

=cut

has 'collection',
    is => 'rw', isa => 'Object', predicate => 'has_collection',
    ;

=head2 (get_|set_)collection_class

The class name of the collection object this recipe will produce.

=cut

has 'collection_class',
    is => 'rw', isa => 'Str', default => Collection,
    ;

=head1 METHODS

=head2 BUILD($param)

L<Moose> method. Initializes C<collection> if not passed to
constructor.

=cut

sub BUILD {
    my ($self, $param) = @_;

    unless ($self->has_collection) {
        $self->set_collection($self->get_collection_class->new);
    }
}

=head2 install($target_class)

Installs the collection and the base class into the C<$target_class>.

=cut

sub install {
    my ($self, $target_class) = @_;
    return $self->get_collection
        ->install($target_class, $self->get_base_class);
}

=head1 SEE ALSO

L<Class::Component::Recipe::Collection> for the collection interface. 
L<NEXT>, L<C3> for component designing systems with multiple inheritance.

=head1 REQUIRES

L<aliased>, L<Class::Inspector>, L<Carp::Clan>, L<Moose>, L<Moose::Policy>,
L<Test::More> (for build).

=head1 AUTHOR

Robert 'phaylon' Sedlacek C<E<lt>phaylon@dunkelheit.atE<gt>>

=head1 LICENSE AND COPYRIGHT

This program is free software, you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
