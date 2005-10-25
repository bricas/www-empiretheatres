package WWW::EmpireTheatres::Showtime;

=head1 NAME

WWW::EmpireTheatres::Showtime - Class representing the showing of a film

=head1 SYNOPSIS

	my $show = WWW::EmpireTheatres::Showtime->new( {
			film     => $film,
			cinema   => $cinema,
			datetime => $datetime
	} );

=head1 DESCRIPTION

This is a simple class to represent when $film is shown at $cinema. The
date and time are (for now) stored as a sting.

=cut

use base qw( Class::Accessor );
use strict;

our $VERSION = '0.02';

__PACKAGE__->mk_accessors( qw( cinema film datetime ) );

=head1 METHODS

=head2 new( [\%options] )

Creates a new WWW::EmpireTheatres::Showtime object.

=head2 cinema( )

The WWW::EmpireTheatres::Cinema object associated with the showing.

=head2 film( )

The WWW::EmpireTheatres::Film object associated with the showing.

=head2 datetime( )

A string representing the date and time of the showing.

=head1 AUTHOR

=over 4

=item * Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2005 by Brian Cassidy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;