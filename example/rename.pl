#!/usr/bin/env perl
use strict;
use warnings;

@ARGV == 1 or die "Usage: perl $0 dir\n";
my ($dir) = @ARGV;

chdir $dir;

foreach my $file (glob "*.SAC") {
    my ($year, $jday, $hour, $min, $sec, $msec,
    $net, $sta, $loc, $chn, $q, $suffix) = split /\./, $file;
    rename $file, "$net.$sta.$loc.$chn.SAC";
}

chdir "..";