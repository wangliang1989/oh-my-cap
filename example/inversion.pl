#!/usr/bin/env perl
use strict;
use warnings;
require config;

@ARGV >= 1 or die "Usage: perl $0 dirname";
my @dir = @ARGV;

foreach my $event (@dir){
    my %pars = read_config($event);
    my $weight = $pars{'-Z'};
    die "no weight file\n" if !-e "$event/$weight";

    # 获取反演的震源深度
    my @depth = split /\s+/, $pars{'DEPTH'};
    foreach my $depth (@depth) {
        $depth = "0$depth" if $depth < 10;
        # deal with -M option
        my $cap_args = "$pars{'cap_args'} -M$pars{'MODEL'}_${depth}/$pars{'MAG'}";
        system "cap.pl $cap_args $event";
    }
}
