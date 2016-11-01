#!/usr/bin/env perl
use strict;
use warnings;

@ARGV >= 1 or die "perl $0 origin-dir\n";
my @origin = @ARGV;

foreach (@origin) {
    open (IN, "< $_/events.info") or die "can not open file $_/events.info\n";
    foreach (<IN>) {
        my ($event) = split /\s+/;
        system "perl rdseed.pl $event";
        system "perl eventinfo.pl $event";
        system "perl marktime.pl $event";
        system "perl transfer.pl $event";
        system "perl rotate.pl $event";
        system "perl resample.pl $event 0.2";
    }
}
