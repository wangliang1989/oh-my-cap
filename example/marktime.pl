#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw(min);
$ENV{SAC_DISPLAY_COPYRIGHT} = 0;

@ARGV == 1 or die "Usage: perl $0 dir\n";
my ($dir) = @ARGV;

chdir $dir;

open(SAC, "| sac") or die "Error in opening SAC\n";
print SAC "wild echo off\n";
foreach my $Zfile (glob "*Z.SAC") {
    my ($net, $sta) = split /\./, $Zfile;
    my (undef, $evdp, $gcarc) = split /\s+/, `saclst evdp gcarc f $Zfile`;
    my @time = split /\s+/, `taup_time -mod prem -ph P,p,Pn -h $evdp -deg $gcarc --time`;
    my $t0 = min @time;

    print SAC "r ${net}.${sta}.*.SAC\n";
    print SAC "ch t0 $t0\n";
    print SAC "ch kt0 Pnl\n";
    print SAC "wh\n";
}
print SAC "q\n";
close(SAC);

chdir "..";
