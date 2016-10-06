#!/usr/bin/env perl
use strict;
use warnings;

@ARGV == 1 or die "Usage: perl $0 dir\n";
my ($dir) = @ARGV;

system "grep -h Event $dir/*_*.out > junk.out";
system "depth.pl junk.out $dir > junk.ps";
unlink "junk.out";
system "mv junk.ps ./$dir/depth.ps";