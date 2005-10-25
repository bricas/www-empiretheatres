use ExtUtils::MakeMaker;

WriteMakefile(
	NAME         => 'WWW::EmpireTheatres',
	VERSION_FROM => 'lib/WWW/EmpireTheatres.pm',
	PREREQ_PM    => {
		'Test::More'               => 0,
		'Test::MockModule'         => 0,
		'Class::Accessor'          => 0,
		'WWW::Mechanize'           => 0,
		'URI'                      => 0,
		'HTML::TokeParser::Simple' => 3
	},
);
