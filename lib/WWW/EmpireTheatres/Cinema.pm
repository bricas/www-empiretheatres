package WWW::EmpireTheatres::Cinema;

=head1 NAME

WWW::EmpireTheatres::Cinema - A class representing a cinema

=head1 SYNOPSIS

	# what films are playing?
	for my $film ( @{ $cinemas->films } ) {
		printf( "%s\n", $film->title );
	}

	# when is it playing?
	for my $showtime ( @{ $cinema->showtimes( film => $film ) } ) {
		printf( "%s\n", $showtime->datetime );
	}

=head1 DESCRIPTION

This class represents a cinema. You can find out what films playing
and when.

=cut

use base qw( Class::Accessor );

use WWW::EmpireTheatres::Showtime;

use strict;
use URI;
use HTML::TokeParser::Simple;
use Carp;

our $VERSION = '0.02';

__PACKAGE__->mk_accessors( qw( province city name link parent id ) );

=head1 METHODS

=head2 new( [\%options] )

Creates a new WWW::EmpireTheatres::Cinema object.

=head2 showtimes( film => $film [, date => $date ] )

Find out when $film is playing @ $cinema.

=cut

sub showtimes {
	my $self    = shift;
	my %options = @_;
	my $agent   = $self->parent->agent;
	my $film    = $options{ film };
	my $link    = $self->link;

	my $uri      = URI->new( $link );
	my %query    = $uri->query_form;

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

	while( my $token = $parser->get_token ) {
		next unless $token->is_start_tag( 'a' ) and $token->get_attr( 'href' ) =~ /\/movies\/spec_main\.asp/;

		my $uri   = URI->new( $token->get_attr( 'href' ) );
		my %query = $uri->query_form;

		next unless $query{ m_id } == $film->id;

		while( $token = $parser->get_token ) {
			next unless $token->is_start_tag( 'td' ) and $token->get_attr( 'bgcolor' ) and $token->get_attr( 'bgcolor' ) eq 'DACFAF';

			$token    = $parser->get_token;
			my $times = $token->as_is;
			$times    =~ s/(&nbsp;)+$|[\r\n]+//gs;

			for my $time ( split( /&nbsp;&nbsp;/, $times ) ) {
				push @results, WWW::EmpireTheatres::Showtime->new( {
					cinema   => $self,
					film     => $film,
					datetime => $options{ date } . " $time"
				} );
			}

			last;
		}

		last;
	}

	return \@results;
}

=head2 films( )

Find out which films are playing at this cinema.

=cut

sub films {
	my $self    = shift;
	my %options = @_;
	my $agent   = $self->parent->agent;
	my $link    = $self->link;

	my $uri      = URI->new( $link );
	my %query    = $uri->query_form;

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

	while( my $token = $parser->get_token ) {
		next unless $token->is_start_tag( 'a' ) and $token->get_attr( 'href' ) =~ /\/movies\/spec_main\.asp/;

		my $uri   = URI->new( $token->get_attr( 'href' ) );
		my %query = $uri->query_form;

		push @results, $self->parent->film( id => $query{ m_id } );
	}

	return \@results;
}

=head2 name( )

The name of the cinema.

=head2 city( )

The city where the cinema is located.

=head2 province( )

The province where the cinema is located

=head2 link( )

A link to the listing of films playing at this cinema.

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