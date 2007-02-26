use strict;

use Module::Build;

my $build = Module::Build->new(
    module_name        => 'WWW::EmpireTheatres',
    dist_author        => 'Brian Cassidy <bricas@cpan.org>',
    license            => 'perl',
    create_readme      => 1,
    create_makefile_pl => 'traditional',
    requires           => {
        'Class::Accessor'          => 0,
        'WWW::Mechanize'           => 0,
        'URI'                      => 0,
        'HTML::TokeParser::Simple' => 3,
    },
    build_requires     => {
        'Test::More'       => 0,
        'Test::MockModule' => 0,
    }
);

$build->create_build_script;
