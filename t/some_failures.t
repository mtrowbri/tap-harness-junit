#!/usr/bin/perl

my $record = $ENV{T_REC};

use TAP::Harness::JUnit;
use Test::More;
use XML::Simple;
use File::Temp;
use File::Basename;
use Encode;

my %tests = (
	some_failures	=> 'Mix of successful and failed checks',
);

plan tests => 2 * int (keys %tests);

my $our_cat  = [$^X, qw/-ne print/];
my $our_cat2 = join(' ', @$our_cat);

foreach my $test (keys %tests) {
	my $model = dirname($0)."/tests/$test.xml";
	my $outfile = ($record ? $model : File::Temp->new (UNLINK => 0)->filename);

	$harness = new TAP::Harness::JUnit ({
		xmlfile     => $outfile,
		verbosity   => -1,
		merge       => 1,
		exec        => $our_cat,
		notimes     => 1,
	});

	$harness->runtests ([dirname($0)."/tests/$test.txt" => $tests{$test}]);

	unless ($record) {
		is_deeply (XMLin ($outfile), XMLin ($model), "Output of $test matches model");
		eval { decode ('UTF-8', `$our_cat2 $outfile`, Encode::FB_CROAK) };
		ok (!$@, "Output of $test is valid UTF-8");
		unlink $outfile;
	}
}
