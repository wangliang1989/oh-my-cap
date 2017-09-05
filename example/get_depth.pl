#!/usr/bin/env perl
use strict;
use warnings;
require config;

@ARGV >= 1 or die "Usage: perl $0 dir\n";
my @dir = @ARGV;

foreach my $event (@dir) {
    my %pars = read_config($event);
    chdir "$event" or die "can not open dir $event\n";
    system "grep -h Event $pars{'MODEL'}_*.out > junk.out";
    system "depth.pl junk.out $event > $pars{'MODEL'}_depth.ps";
    system "ps2raster -A -E1080 -P -Tf $pars{'MODEL'}_depth.ps";
    unlink "$pars{'MODEL'}_depth.ps";
    unlink "junk.out";
    chdir "..";
}
