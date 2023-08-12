#!/usr/bin/env perl
use strict;
use warnings;
require "$ENV{'OH_MY_CAP'}/oh-my-cap.pm";

@ARGV >= 1 or die "Usage: perl $0 dirname";
my @dir = @ARGV;

foreach my $event (@dir){
    my %pars = choose_config($event);
    my $weight = $pars{'-Z'};
    die "no weight file\n" unless -e "$event/$weight";

    # 获取反演的震源深度
    my @depth = split m/\s+/, $pars{'DEPTH'};
    foreach (@depth) {
        system "cap.pl $pars{'cap_args'} -M$pars{'MODEL'}_$_/$pars{'MAG'} $event";
    }
}
