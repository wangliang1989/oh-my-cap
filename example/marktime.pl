#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw(min);
use List::Util qw(max);
$ENV{SAC_DISPLAY_COPYRIGHT} = 0;

@ARGV == 1 or die "Usage: perl $0 dir\n";
my ($dir) = @ARGV;

my $taup = `which taup_time`;
exit "Skip marking arrival times in SAC files because Taup isn't install\n" unless (defined($taup));

chdir $dir;

open(SAC, "| sac") or die "Error in opening SAC\n";
print SAC "wild echo off\n";
foreach my $Zfile (glob "*Z.SAC") {
    my ($net, $sta) = split m/\./, $Zfile;
    my (undef, $evdp, $gcarc, $b, $e) = split m/\s+/, `saclst evdp gcarc b e f $Zfile`;
    my @time = split m/\s+/, `taup_time -mod prem -ph P,p,Pn -h $evdp -deg $gcarc --time`;
    my $t0 = min @time;
    my $start = max (0, $b, ($t0 - 30));
    my $end = min ($e, ($t0 + 600));

    if ($start < $end) {
        print SAC "cut $start $end\n";
        print SAC "r ${net}.${sta}.*.SAC\n";
        print SAC "ch t0 $t0\n";
        print SAC "ch kt0 Pnl\n";
        print SAC "write over\n";
    } else {
        unlink glob "${net}.${sta}.*.SAC";
    }
}
print SAC "q\n";
close(SAC);

chdir "..";
