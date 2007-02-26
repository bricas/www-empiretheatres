use Test::More tests => 18;

use Test::MockModule;
use URI::file;

use strict;
use warnings;

BEGIN {
    use_ok( 'WWW::EmpireTheatres' );
}

my $mech = new Test::MockModule( 'WWW::Mechanize', no_auto => 1 );
$mech->mock( get => \&get );

my $theatre = WWW::EmpireTheatres->new;

isa_ok( $theatre, 'WWW::EmpireTheatres' );

my $films = [ (
    'Are We There Yet?',
    'Aviator, The',
    'Be Cool',
    'Because Of Winn-Dixie',
    'Beyond The Sea',
    'Boogeyman',
    'Bride And Prejudice',
    'Chorus, The',
    'Coach Carter',
    'Constantine',
    'Cursed',
    'Daniel And The Superdogs',
    'Daniel Et Les Superdogs',
    'Finding Neverland',
    'Hide And Seek',
    'Hitch',
    'Hotel Rwanda',
    'In Good Company',
    'Jacket, The',
    'Man Of The House',
    'Meet The Fockers',
    'Million Dollar Baby',
    'NASCAR 3D: The IMAX Experience',
    'Ong-Bak: The Thai Warrior',
    'Pacifier, The',
    'Phantom Of The Opera, The',
    'Polar Express, The: IMAX 3D',
    'Pooh\'s Heffalump Movie',
    'Racing Stripes',
    'Sideways',
    'Son Of The Mask',
    'Very Long Engagement, A',
    'Wedding Date, The',
    'What Remains Of Us',
    'Woodsman, The'
) ];

is_deeply( [ map $_->title, sort { $a->title cmp $b->title } @{ $theatre->films } ], $films, 'films() matches' );

my $cinemas = [
    [ 'New Brunswick', 'Dieppe', 'Crystal Palace 8 Cinemas' ],
    [ 'New Brunswick', 'Fredericton', 'Empire 10 Cinemas Regent Mall' ],
    [ 'New Brunswick', 'Miramichi', 'Empire Studio 5' ],
    [ 'New Brunswick', 'Moncton', 'Empire 8, Trinity Drive' ],
    [ 'New Brunswick', 'Rothesay', 'Empire 4 Cinemas' ],
    [ 'New Brunswick', 'Saint John', 'Empire Studio 10' ],
    [ 'New Brunswick', 'Saint John', 'Empire King Square' ],
    [ 'Nova Scotia', 'Amherst', 'Paramount Cinemas' ],
    [ 'Nova Scotia', 'Bedford', 'Empire 6 Cinemas' ],
    [ 'Nova Scotia', 'Bridgewater', 'Empire Studio 7' ],
    [ 'Nova Scotia', 'Dartmouth', 'Empire 5, Penhorn Mall' ],
    [ 'Nova Scotia', 'Dartmouth', 'Empire 6 Cinemas' ],
    [ 'Nova Scotia', 'Halifax', 'Empire 17 Cinemas Bayers Lake' ],
    [ 'Nova Scotia', 'Halifax', 'Oxford Theatre' ],
    [ 'Nova Scotia', 'Halifax', 'Empire IMAX Theatre' ],
    [ 'Nova Scotia', 'Halifax', 'Empire 8, Park Lane' ],
    [ 'Nova Scotia', 'Lower Sackville', 'Empire Studio 7' ],
    [ 'Nova Scotia', 'New Glasgow', 'Empire Studio 7' ],
    [ 'Nova Scotia', 'New Minas', 'Empire 7 Cinemas' ],
    [ 'Nova Scotia', 'Sydney', 'Empire Studio 10' ],
    [ 'Nova Scotia', 'Truro', 'Empire Studio 7' ],
    [ 'Nova Scotia', 'Westville', 'Empire Drive-In' ],
    [ 'Nova Scotia', 'Yarmouth', 'Yarmouth Cinemas' ],
    [ 'Newfoundland', 'Corner Brook', 'Millbrook Cinemas' ],
    [ 'Newfoundland', 'Mount Pearl', 'Empire Cinemas Mount Pearl Shopping Center' ],
    [ 'Newfoundland', 'St. John\'s', 'Empire Studio 12' ],
    [ 'Prince Edward Island', 'Charlottetown', 'Empire Studio 8' ],
    [ 'Prince Edward Island', 'Summerside', 'Empire Studio 5' ]
];

$cinemas        = [ sort { $a->[ 0 ] cmp $b->[ 0 ] || $a->[ 1 ] cmp $b->[ 1 ] || $a->[ 2 ] cmp $b->[ 2 ] } @$cinemas ];
my $got_cinemas = [ map { [ $_->province, $_->city, $_->name ] } sort { $a->province cmp $b->province || $a->city cmp $b->city || $a->name cmp $b->name } @{ $theatre->cinemas } ];

is_deeply( $got_cinemas, $cinemas, 'cinemas() matches' );

my $film = $theatre->film( title => 'Be Cool' );

isa_ok( $film, 'WWW::EmpireTheatres::Film' );
is( $film->title, 'Be Cool', 'correct film' );

my $cinema = $theatre->cinema( city => 'Fredericton' );

isa_ok( $cinema, 'WWW::EmpireTheatres::Cinema' );
is( $cinema->city, 'Fredericton', 'correct cinema' );

$films = [
    'Are We There Yet?',
    'Because Of Winn-Dixie',
    'Boogeyman',
    'Constantine',
    'Cursed',
    'Hitch',
    'Hotel Rwanda',
    'Man Of The House',
    'Million Dollar Baby',
    'Son Of The Mask',
    'Wedding Date, The'
];

is_deeply( [ map $_->title, sort { $a->title cmp $b->title } @{ $cinema->films } ], $films, '$cinema->films() matches' );

is( @{ $film->cinemas }, 0, 'Film not playing today' );

$cinemas = [
    [ 'New Brunswick', 'Fredericton', 'Empire 10 Cinemas Regent Mall' ],
    [ 'New Brunswick', 'Moncton', 'Empire 8, Trinity Drive' ],
    [ 'New Brunswick', 'Miramichi', 'Empire Studio 5' ],
    [ 'New Brunswick', 'Rothesay', 'Empire 4 Cinemas' ],
    [ 'New Brunswick', 'Saint John', 'Empire Studio 10' ],
    [ 'Nova Scotia', 'Bridgewater', 'Empire Studio 7' ],
    [ 'Nova Scotia', 'Lower Sackville', 'Empire Studio 7' ],
    [ 'Nova Scotia', 'New Glasgow', 'Empire Studio 7' ],
    [ 'Nova Scotia', 'Truro', 'Empire Studio 7' ],
    [ 'Nova Scotia', 'New Minas', 'Empire 7 Cinemas' ],
    [ 'Nova Scotia', 'Dartmouth', 'Empire 6 Cinemas' ],
    [ 'Nova Scotia', 'Bedford', 'Empire 6 Cinemas' ],
    [ 'Nova Scotia', 'Halifax', 'Empire 8, Park Lane' ],
    [ 'Nova Scotia', 'Halifax', 'Empire 17 Cinemas Bayers Lake' ],
    [ 'Nova Scotia', 'Sydney', 'Empire Studio 10' ],
    [ 'Newfoundland', 'Mount Pearl', 'Empire Cinemas Mount Pearl Shopping Center' ],
    [ 'Newfoundland', 'St. John\'s', 'Empire Studio 12' ],
    [ 'Prince Edward Island', 'Charlottetown', 'Empire Studio 8' ],
    [ 'Prince Edward Island', 'Summerside', 'Empire Studio 5' ]
];

$cinemas     = [ sort { $a->[ 0 ] cmp $b->[ 0 ] || $a->[ 1 ] cmp $b->[ 1 ] || $a->[ 2 ] cmp $b->[ 2 ] } @$cinemas ];
$got_cinemas = [ map { [ $_->province, $_->city, $_->name ] } sort { $a->province cmp $b->province || $a->city cmp $b->city || $a->name cmp $b->name } @{ $film->cinemas( date => '3/4/2005' ) } ];

is_deeply( $got_cinemas, $cinemas, '$film->cinemas() matches' );

my $showtimes = $theatre->showtimes( film => $film, cinema => $cinema );

is( @{ $showtimes }, 0, 'Film not playing today' );

$showtimes = $cinema->showtimes( film => $film );

is( @{ $showtimes }, 0, 'Film not playing today' );

$showtimes = $film->showtimes( cinema => $cinema );

is( @{ $showtimes }, 0, 'Film not playing today' );

$showtimes = $cinema->showtimes( film => $film, date => '3/4/2005' );

isa_ok( $showtimes->[ 0 ], 'WWW::EmpireTheatres::Showtime' );
isa_ok( $showtimes->[ 1 ], 'WWW::EmpireTheatres::Showtime' );

is( $showtimes->[ 0 ]->datetime, '3/4/2005 6:35', 'first showtime' );
is( $showtimes->[ 1 ]->datetime, '3/4/2005 9:20', 'second showtime' );

sub get {
    my $self = shift;
    my $url  = shift;

    my $file;

    if( $url =~ /new_showtime_by_movie1\.asp/ ) {
        if( $url =~ /Day/ ) {
            $file = 'be_cool_playing.html';
        }
        else {
            $file = 'be_cool.html';
        }
    }
    elsif( $url =~ /new_showtime_by_theatre1\.asp/ ) {
        if( $url =~  /t_id=22&Day=3%2F4%2F2005/ ) {
            $file = 'fredericton_be_cool.html';
        }
        else {
            $file = 'fredericton.html';
        }
    }
    else {
        $file = ( split( /\//, $url ) )[ -1 ];
    }

    my $uri = URI::file->new_abs( "t/data/$file" );

    return LWP::UserAgent::get( $self, $uri->as_string );
}
