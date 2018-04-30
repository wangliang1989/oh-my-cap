#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
require config;

@ARGV >= 1 or die "Usage: perl $0 dirname";
my @dir = @ARGV;

foreach my $event (@dir){
    my %pars = read_config($event);
    my $weight = $pars{'-Z'};
    die "no weight file\n" if !-e "$event/$weight";

    # 获取反演的震源深度
    my @depth = split m/\s+/, $pars{'DEPTH'};
    foreach my $depth (@depth) {
        # deal with -M option
        my $cap_args = "$pars{'cap_args'} -M$pars{'MODEL'}_${depth}/$pars{'MAG'}";
        print "cap.pl $cap_args $event\n";
        unlink "$event/$pars{'MODEL'}_${depth}.ps";
        system "cap.pl $cap_args $event";
        system "ps2raster -P -Tf $event/$pars{'MODEL'}_${depth}.ps";
        unlink "$event/$pars{'MODEL'}_${depth}.ps";
        print "\n";
    }
}
