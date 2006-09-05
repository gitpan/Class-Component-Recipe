=head1 NAME

Class::Component::Recipe::Collection 

=cut

package Class::Component::Recipe::Collection;
use warnings;
use strict;

use Carp::Clan qw(^Class::Component::Recipe::);
use Class::Inspector;

use Moose::Policy 'Moose::Policy::FollowPBP';
use Moose;

=head1 ATTRIBUTES

=head2 classes

The actual list of classes. Provides C<get_classes> and C<set_classes>.
Has to be an ArrayRef and is empty by default.

=cut

has 'classes',
    is => 'rw', isa => 'ArrayRef', default => sub {[]},
    ;

=head1 METHODS

=head2 install($target_class, $base_class)

Installs the list of L<classes> and the C<$base_class> in the
C<$target_class>.

=cut

sub install {
    my ($self, $target_class, $base_class) = @_;
    
    unless (Class::Inspector->loaded($target_class)) {
        eval qq(
            package $target_class;
        );
    }
    my $target_ISA = do {
        no strict 'refs';
        \@{$target_class . '::ISA'}
    };

    my @classes;

    $self->_ensure_loaded_class($base_class);
    push @classes, $base_class if defined $base_class;

    push @classes, @{$self->get_classes};
    $self->_ensure_loaded_class($_) for @classes;
    push @$target_ISA, reverse(@classes);

    1;
}

=head2 _ensure_loaded_class($class)

Takes care that the passed class name is loaded.

=cut

sub _ensure_loaded_class {
    my ($self, $class) = @_;

    unless (Class::Inspector->loaded($class)) {
        require Class::Inspector->filename($class);
    }

    1;
}

=head2 push($class, [$force])

Pushes a class at the end of the list.

If the C<$class> is already present in the list, this is a no-op and will
return C<0>. This can be changed by specifying a positive value for
C<$force>, which will remove the existing element before pushing. If the
list has been changed, a C<1> is returned.

=cut

sub push {
    my ($self, $class, $force) = @_;
    
    croak 'push needs a class name as first argument'
        unless defined $class;

    if ($self->has_class($class)) {
        return 0 unless $force;
        $self->remove($class);
    }
        
    push @{$self->get_classes}, $class;

    return 1;
}

=head2 pop()

Returns and removes the last element of the list.

=cut

sub pop {
    my ($self) = @_;
    
    pop @{$self->get_classes};
}

=head2 unshift($class, [$force])

Pushes a class at the beginning of the list.

If the class is already present, this will be a no-op and just return
C<0>. If the C<$force> value is set to a positive value, any existing
value will be removed before the unshifting. If the list was changed,
a C<1> is returned.

=cut

sub unshift {
    my ($self, $class, $force) = @_;

    croak 'unshift needs a class name as first argument'
        unless defined $class;

    if ($self->has_class($class)) {
        return 0 unless $force;
        $self->remove($class);
    }

    unshift @{$self->get_classes}, $class;

    return 1;
}

=head2 shift()

Returns and removes the first element from the list.

=cut

sub shift {
    my ($self) = @_;

    shift @{$self->get_classes};
}

=head2 insert($class, $position, [$force])

Inserts C<$class> in the list at C<$position>.

If the class already exists in the list, this is a no-op and will just
return C<0>. If the <$force> value is set to a positive value any other
mentioning of the class in the list will be removed first. If the list
got changed a C<1> is returned.

=cut

sub insert {
    my ($self, $class, $position, $force) = @_;

    croak 'insert needs class name as first argument'
        unless defined $class;

    croak 'insert needs position as second argument'
        unless defined $position;
    
    my @curr = @{$self->get_classes};
    croak 'position argument is out of range'
        if $position > ($#curr + 1);

    my @pre  = @curr[0 .. ($position - 1)];
    my @post = @curr[$position .. $#curr];

    if ($self->has_class($class)) {
        return 0 unless $force;

        for my $l (\@pre, \@post) {
            @$l = grep { $class ne $_ } @$l;
        }
    }
        
    $self->set_classes([@pre, $class, @post]);

    return 1;
}

=head2 remove($class)

This removes the C<$class> from the list. If C<$class> is not even in
the list, it returns C<0>, otherwise C<1> if it really changed something.

=cut

sub remove {
    my ($self, $class) = @_;

    croak 'remove needs class name as first argument'
        unless defined $class;

    return 0 unless $self->has_class($class);

    $self->set_classes([ 
        grep { $_ ne $class } @{$self->get_classes} ]);

    return 1;
}

=head2 replace($class, $replacement)

This will replace C<$class> in the list with C<$replacement>. The call
will C<croak> if the C<$class> is not even in the list.

=cut

sub replace {
    my ($self, $class, $replacement) = @_;

    croak 'replace needs class name as first argument'
        unless defined $class;

    croak 'replace needs replacement as second argument. use remove '
        . 'to get classes out of the class list.'
        unless defined $replacement;

    my $position = $self->get_position_of($class);

    croak "class '$class' is not in the class list, can't replace"
        unless defined $position;

    $self->remove($class);    
    $self->insert($replacement, $position);

    1;
}

=head2 get_position_of($class)

Returns the position of the class in the list (zero based) or C<undef>
if it's not in there.

=cut

sub get_position_of {
    my ($self, $class) = @_;

    croak 'get_position_of needs class name as first argument'
        unless defined $class;

    for (0 .. $#{$self->get_classes}) {
        return $_ if $class eq $self->get_classes->[$_];
    }

    return undef;
}

=head2 has_class($class)

This predicate returns true or false depending on the existance of 
C<$class> in the list.

=cut

sub has_class {
    my ($self, $class) = @_;

    croak 'has_class predicate needs class name as first argument'
        unless defined $class;
    
    return ! ! grep { $_ eq $class } @{$self->get_classes};
}

=head1 AUTHOR

Robert 'phaylon' Sedlacek C<E<lt>phaylon@dunkelheit.atE<gt>>

=head1 LICENSE AND COPYRIGHT

This program is free software, you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
