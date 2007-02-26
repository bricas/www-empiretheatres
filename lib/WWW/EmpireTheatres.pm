package WWW::EmpireTheatres;

=head1 NAME

WWW::EmpireTheatres - Get film listings for the Empire Theatres cinema chain

=head1 SYNOPSIS

    use WWW::EmpireTheatres;
    
    my $empire = WWW::EmpireTheatres->new;

    # what films are currently playing in all locations
    for my $film ( @{ $empire->films } ) {
        printf( "%s\n", $film->title );
    }

    # what locations are there?
    for my $cinema ( @{ $empire->cinemas } ) {
        printf( "%s (%s, %s)\n", $cinema->name, $cinema->city, $cinema->province );
    }

    my $film   = $empire->film( title => 'SpongeBob' );
    my $cinema = $empire->cinema( city => 'Fredericton' );

    # get today's showtimes for SpongeBob @ Fredericton
    for my $showtime ( @{ $cinema->showtimes( film => $film ) } ) {
        printf( "%s\n", $showtime->datetime );
    }

    # where is the film playing?
    for my $cinema ( @{ $film->cinemas } ) {
        printf( "%s (%s, %s)\n", $cinema->name, $cinema->city, $cinema->province );
    }

    # what films are playing?
    for my $film ( @{ $cinema->films } ) {
        printf( "%s\n", $film->title );
    }

=head1 DESCRIPTION

This module does some basic screen scraping of the http://www.empiretheatres.com/
website to provide a listing of films, cinemas and showtimes.

=cut

use base qw( Class::Accessor );

use strict;
use warnings;

use WWW::EmpireTheatres::Film;
use WWW::EmpireTheatres::Cinema;

use WWW::Mechanize;
use HTML::TokeParser::Simple;
use Carp;

use constant BASE_URL    => 'http://www.empiretheatres.com';
use constant FILMS_URL   => BASE_URL . '/showtimes/by_movie.asp';
use constant CINEMAS_URL => BASE_URL . '/theatres/by_theatre.asp';

our $VERSION = '0.05';

__PACKAGE__->mk_accessors( qw( films cinemas agent ) );

=head1 METHODS

=head2 new()

Creates a new object and gets the film and cinema listing.

=cut

sub new {
    my $class = shift;
    my $self  = { };

    bless $self, $class;

    $self->agent( WWW::Mechanize->new );

    $self->get_listings;

    return $self;
}

=head2 get_listings( )

This method scrapes the film and cinema listing on the website. It is
automatically called when new() is called.

=cut

sub get_listings {
    my $self  = shift;
    my $agent = $self->agent;
    my $parser;

    $agent->get( FILMS_URL );
    croak( 'Error fetching listings' ) unless $agent->success;
    $parser = HTML::TokeParser::Simple->new( string => $agent->content );
    $parser->unbroken_text( 1 );

    my @films;
    while( my $token = $parser->get_token ) {
        unless(
            $token->is_start_tag( 'a' ) and
            $token->get_attr( 'href' ) =~ /^\/theatres\/new_showtime_by_movie1\.asp\?movie=/
        ) {
            next;
        }

        my $link  = $token->get_attr( 'href' );
        $token    = $parser->get_token;

        my $title = $token->as_is;
        $title    =~ s/\s+\(.*\)//;

        my $uri   = URI->new( $link );
        my %query = $uri->query_form;

        push @films, WWW::EmpireTheatres::Film->new( {
            id     => $query{ m_id },
            parent => $self,
            title  => $title,
            link   => BASE_URL . $link
        } );
    }

    $self->films( @films );

    $agent->get( CINEMAS_URL );
    croak( 'Error fetching listings' ) unless $agent->success;
    $parser = HTML::TokeParser::Simple->new( string => $agent->content );
    $parser->unbroken_text( 1 );

    my @cinemas;
    my $capture = 0;
    while( my $token = $parser->get_token ) {
        if(
            not $capture and
            $token->is_start_tag( 'td' ) and
            defined $token->get_attr( 'class' ) and
            $token->get_attr( 'class' ) eq 'etbody'
        ) {
            $capture = 1;
        }

        next unless $capture;

        # Skip to province name
        $token = $parser->get_token;
        $token = $parser->get_token;

        my $province = $token->as_is;

        my @temp;

        # parse locations
        while( my $token = $parser->get_token ) {
            last if $token->is_end_tag( 'td' );

            if( @temp and $token->is_start_tag( 'br' ) ) {
                $temp[ -1 ]->{ count } += 0.5;
            }
            elsif( $token->is_text ) {
                my $text = $token->as_is;
                $text =~ s/^\s+(&nbsp;)+|\s+$//gs;
                next unless $text;

                $temp[ -1 ]->{ count } = int( $temp[ -1 ]->{ count } ) if @temp;

                push @temp, { city => $text, count => 0 };
            }
        }

        # parse names
        my $loc   = 0;
        my $count = 0;
        while( my $token = $parser->get_token ) {
            last if $token->is_end_tag( 'td' );
            next unless $token->is_start_tag( 'a' );
            my $link = $token->get_attr( 'href' );

            $token = $parser->get_token;

            next if $token->as_is =~ /<img/;

            my $name  = $token->as_is;

            $token = $parser->get_token;

            if( $token->as_is =~ /<br/ ) {
                $token = $parser->get_token;
                $name .= ' ' . $token->as_is;
            }            

            my $uri   = URI->new( BASE_URL . $link );
            my %query = $uri->query_form;

            push @cinemas, WWW::EmpireTheatres::Cinema->new( {
                parent   => $self,
                id       => $query{ TH_ID } || $query{ th_id },
                link     => $uri->as_string,
                name     => $name,
                province => $province,
                city     => $temp[ $loc ]->{ city }
            } );

            $count++;

            if( $loc != $#temp and $count >= $temp[ $loc ]->{ count } ) {
                $count = 0;
                $loc++;
            }
        }

        $capture = 0;
    }

    $self->cinemas( @cinemas );
}

=head2 film( %options )

This allows you to search for a film. You can pass a portion of the title and/or it's internal id.

    # Christmas With The Kranks
    $empire->film( title => 'Kranks' );

=cut

sub film {
    my $self    = shift;
    my %options = @_;

    for( @{ $self->films } ) {
        my $match = 1;
        for my $field ( qw( title id ) ) {
            if( $options{ $field } ) {
                if( $field eq 'id' and $options{ id } !=  $_->id ) {
                    $match = 0;
                }
                if( $field eq 'title' and lc( $_->title ) !~  /$options{ title }/i ) {
                    $match = 0;
                }
            }
        }

        return $_ if $match;
    }
}

=head2 cinema( %options )

This allows you to search for a cinema. You can pass the name, city, provice and/or
the internal id. It returns the first successful match.

    # Empire 10 Cinemas Regent Mall, Fredericton, New Brunswick
    $empire->cinema( city => 'Fredericton' );

=cut


sub cinema {
    my $self   = shift;
    my %options = @_;

    for( @{ $self->cinemas } ) {
        my $match = 1;
        for my $field ( qw( province city name id ) ) {
            if( $options{ $field } ) {
                if( lc( $options{ $field } ) ne lc( $_->$field ) ) {
                    $match = 0;
                }
            }
        }

        return $_ if $match;
    }
}

=head2 showtimes( film => $film, cinema => $cimena [, date => $date ] )

Returns the showtimes for $film @ $cinema on $date (or today if no date
is specified)

=cut

sub showtimes {
    my $self    = shift;
    my %options = @_;

    return $options{ cinema }->showtimes( @_ );
}

=head2 films( )

Returns the list of films

=head2 cinemas( )

Returns the list cinemas

=head2 agent( )

Returns the internal WWW::Mechanize object

=head1 AUTHOR

=over 4

=item * Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Brian Cassidy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;
