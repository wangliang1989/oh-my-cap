#!/usr/bin/env perl
use strict;
use warnings;

@ARGV == 1 or die "Usage: perl $0 dirname";
my ($event) = @ARGV;

die "no weight.dat\n" if !-e "$event/weight.dat";

for (my $depth = 5; $depth <= 30; $depth = $depth + 5) {
    if ($depth < 10) {
        $depth = "0$depth";
    }
    system "cap.pl -H0.2 -P0.3 -S5/10/0 -T35/70 -D2/1/0.5 -C0.05/0.3/0.02/0.1 -W1 -X10 -Mmodel_$depth/5.0 $event";
}
