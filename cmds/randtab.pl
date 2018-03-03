#!/usr/bin/perl
use strict;
sub fail{print "Bad table. My beak hurts. (did you buy it from IKEA?)\n";exit 0}
$ARGV[0] =~ /(\/[a-zA-Z]*\s+)?(?<tabname>[a-zA-Z]*)/ or die;
my $fn = $+{tabname};
open(FILE, "<", ("./tables/" . $fn)) or fail();
my $line;
rand($.)<1 and ($line=$_) while <FILE>;
close FILE;
print "$line";
