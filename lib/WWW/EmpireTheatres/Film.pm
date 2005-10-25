package WWW::EmpireTheatres::Film;

=head1 NAME

WWW::EmpireTheatres::Film - A class representing a film

=head1 SYNOPSIS

	# where is the film playing?
	for my $cinema ( @{ $film->cinemas } ) {
		printf( "%s (%s, %s)\n", $cinema->name, $cinema->city, $cinema->province );
	}

	# when is it playing?
	for my $showtime ( @{ $film->showtimes( cinema => $cinema ) } ) {
		printf( "%s\n", $showtime->datetime );
	}

=head1 DESCRIPTION

This class represents a film. You can find out what cinemas it's playing
and when it's playing.

=cut

use base qw( Class::Accessor );

use strict;
use URI;
use HTML::TokeParser::Simple;
use Carp;

our $VERSION = '0.03';

__PACKAGE__->mk_accessors( qw( title link parent id ) );

=head1 METHODS

=head2 new( [\%options] )

Creates a new WWW::EmpireTheatres::Film object.

=head2 showtimes( cinema => $cinema [, date => $date ] )

Find out when $film is playing @ $cinema.

=cut

sub showtimes {
	my $self    = shift;
	my %options = @_;

	return $options{ cinema }->showtimes( film => $self, @_ );
}

=head2 cinemas( )

Find out which cinemas have this film.

=cut

sub cinemas {
	my $self = shift;
	my %options = @_;
	my $agent   = $self->parent->agent;
	my $link    = $self->link;

	my $uri     = URI->new( $link );
	my %query   = $uri->query_form;

	if( $options{ date } ) {
		$query{ Day } = $options{ date };

		$uri->query_form( \%query );

		$link = $uri->as_string;
	}
	else {
		$options{ date } = $query{ Day };
	}


	$agent->get( $link );
	croak( 'Error fetching listings' ) unless $agent->success;
	my $parser = HTML::TokeParser::Simple->new( string => $agent->content );

	my @results;

	if( $agent->content =~ /Sorry, this movie is not playing on the selected day/ ) {
		return \@results;
	}

	while( my $token = $parser->get_token ) {
		next unless $token->is_start_tag( 'font' ) and $token->get_attr( 'color' ) and $token->get_attr( 'color' ) eq '#FFFFFF';

		while( $token = $parser->get_token ) {
			last if $token->is_start_tag( 'img' ) and $token->get_attr( 'src' ) eq 'images/spacer.gif';
			next unless $token->is_start_tag( 'a' );

			my $uri   = URI->new( $token->get_attr( 'href' ) );
			my %query = $uri->query_form;

			push @results, $self->parent->cinema( id => $query{ TH_ID } || $query{ th_id } );
		}
	}

	return \@results;
}

=head2 title( )

The title of the film.

=head2 link( )

A link to the listing of the cinemas that have this film.

=head2 id( )

The internal id used on the website.

=head2 parent( )

The parent WWW::EmpireTheatres object.

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