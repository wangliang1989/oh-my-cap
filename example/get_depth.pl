#!/usr/bin/env perl
use strict;
use warnings;

@ARGV >= 1 or die "Usage: perl $0 dir\n";
my @dir = @ARGV;

foreach my $dir (@dir) {
    chdir "$dir" or die "can not open dir $dir\n";
    system "grep -h Event *_*.out > junk.out";
    system "depth.pl junk.out $dir > depth.ps";
    unlink "junk.out";
    chdir "..";
}
