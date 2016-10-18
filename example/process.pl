#!/usr/bin/env perl
use strict;
use warnings;

@ARGV >= 1 or die "Usage: perl $0 event1 event2 ... eventn\n";

foreach my $event (@ARGV) {
    system "perl rdseed.pl $event";
    system "perl eventinfo.pl $event";
    system "perl marktime.pl $event";
    system "perl transfer.pl $event";
    system "perl rotate.pl $event";
    system "perl resample.pl $event 0.2";
}
