#!/usr/bin/env perl

use JSON::PP;

$runcmd = sub {
	my $cmd = shift;
	my $out = `$cmd 2>&1`;
	if($?) { die "\e[31mFailed:\e[0m\n$cmd\n";}
	else { return $out; }
};



$pull = sub {
	print "Pulling...\n";
	my $link = shift;
	return sub {
		my $name = shift;
		# my $out = `if [ -f ".git" ]; then echo "yes"; else echo "no"; fi 2>&1`;
		# if($out == "no") {
		# 	my $out = $runcmd->("git init");
		# 	$out = $runcmd->("git branch -m master main");
		# 	$out = $runcmd->("git remote add $name $link");
		# }
		$out = $runcmd->("git pull $name main");
	}
};

$test = sub {
	print "Testing...\n";
	my $testdir = shift;
	my $file_contents = open(my $in,'<','tests.track.json') or '';
	if($file_contents) {
		my $trackingref = decode_json $file_contents;
		my %tracking = $$trackingref;
	}
	else {
		my $out = `touch tests.track.json`;
		my %tracking = ();
	}
	# Non-regression tests
	my $passcount = 0;
	my $i = 0;
	my @undone_tests = ();
	my $out = $runcmd->("ls $testdir");
	@testfiles = split("\n",$out);
	foreach $test (@testfiles) {
		unless(exists $tracking{$test}) {
			push(@undone_tests, $test); 
			next;
		}
		my $testresult = `php $testdir/$test 2>&1`;
		unless($?) { $passcount++; $tracking{$test} = "passed"; } else { $tracking{$test} = "failed"; }
		$i++;
	}
	$failed = $i - $passcount;
	print "Non-regression tests: ";
	if($failed==0) {
		print "\e[32mTests Passed [$passcount/$i]\e[0m\n";
	} else {
		print " \e[31mTests Passed [$passcount/$i] (Some tests failed, see 'tests.track.json' file)\e[0m\n";
	}
	# Newly pulled tests
	$size = @undone_tests;
	unless($size == 0) {
		$passcount = 0;
		$i = 0;
		foreach $test (@undone_tests) {
			my $testresult = `php $testdir/$test 2>&1`;
			unless($?) { $passcount++; $tracking{$test} = "passed"; } else { $tracking{$test} = "failed"; }
			$i++;
		}
		$failed = $i - $passcount;
		print "Newly added tests: ";
		if($failed==0) {
			print "\e[32mTests Passed [$passcount/$i]\e[0m\n";
		} else {
			print " \e[31mTests Passed [$passcount/$i] (Some tests failed, see 'tests.track.json' file)\e[0m\n";
		}
	}
	$ptr = \%tracking;
	$track_json = encode_json $ptr;
	open(my $output_file,'>','tests.track.json') or die "\e[31mCouldn't open file 'tests.track.json' for writing\e[0m\n";
	print $output_file $track_json;
	print "\e[32mAdded new tests\e[0m\n";
};

$copy = sub {
	print "Copying files...\n";
	my $source = shift;
	return sub {
		my $destination = shift;
		my $out = $runcmd->("cp -r $source $destination");
	};
};

$launch = sub {
	print "Launching server...\n";
	foreach $command (@commands) {
		my $out = $runcmd->($command);
	};
};

sub main {
	$runcmd->("stat conf.pl");
	$config = do "./conf.pl";
	$link = $config->{link};
	$name = (exists $config->{name}) ? $config->{name} : "origin";
	$tests = $config->{tests};
	$source = (exists $config->{source}) ? $config->{source} : "";
	$target = (exists $config->{target}) ? $config->{target} : "";
	@commands = $config->{commands};

	my $arg = shift;
	if($arg eq 'stage') {
		print "--- Staging ---\n";
		$pull->($link)->($name);
		$test->($tests);
		print "--- Done staging ---\n";
	}
	elsif($arg eq 'deploy') {
		print "--- Deploying ---\n";
		$copy->($source)->($target);
		$launch->(@commands);
		print "--- Done deploying ---\n";
	}
	elsif($arg eq 'info') {
		print "--- Test Info ---\n";
		$out = `cat tests.track.json`;
		print "$out\n";
	}
	else { print "Usage:\nintegr stage\t\tPull the changes from the repo, run tests, if successful commit them to tests track then run new tests and update test track with the result status\nintegr deploy\t\tCopy the files to the correct place if needed then (re)start the web server\nintegr info\t\tDump info about past tests, basically prints out the contents of 'tests.track.json'\n"; }

}

main($ARGV[0]);
