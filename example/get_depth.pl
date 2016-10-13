#!/usr/bin/env perl
use strict;
use warnings;

@ARGV == 1 or die "Usage: perl $0 dir\n";
my ($dir) = @ARGV;

chdir "$dir";
system "grep -h Event *_*.out > junk.out";
system "depth.pl junk.out $dir > depth.ps";
unlink "junk.out";
chdir "..";
