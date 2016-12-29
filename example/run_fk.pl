#!/usr/bin/env perl
use strict;
use warnings;
require config;

@ARGV >= 1 or die "Usage: perl $0 dirname";
my @dir = @ARGV;

foreach my $event (@dir){
    my %pars = read_config($event);
    my $fname = $pars{"FKMODEL"};
    my ($model) = split m/\./, $fname;
    my $nt = $pars{"NT"};
    my $dt = $pars{"DT"};
    my @dist = split m/\s+/, $pars{"DIST"};
    my @depth = split m/\s+/, $pars{"FKDEPTH"};
    my $fkdir = "$ENV{OH_MY_CAP}/Glib";
    $fkdir = $pars{"FKDIR"} if defined($pars{"FKDIR"});
    my $flat = "YES";
    $flat = $pars{"FLAT"} if defined($pars{"FLAT"});

    chdir $fkdir or die;
    mkdir $model unless (-d $model);
    system "cp $fname $model/$model";
    chdir $model or die;

    foreach my $depth (@depth) {
        $depth = "0$depth" if ($depth < 10);
        if ($flat eq "YES") {
            # 计算双力偶
            system "fk.pl -M$model/$depth/f -N$nt/$dt -S2 @dist";
            # 计算爆炸源
            system "fk.pl -M$model/$depth/f -N$nt/$dt -S0 @dist";
        } elsif ($flat eq "NO") {
            # 计算双力偶
            system "fk.pl -M$model/$depth -N$nt/$dt -S2 @dist";
            # 计算爆炸源
            system "fk.pl -M$model/$depth -N$nt/$dt -S0 @dist";
        } else {
            die "I don't know you want flat or not!\n";
        }
    }
    unlink glob "junk.*";
}
