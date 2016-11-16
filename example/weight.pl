#!/usr/bin/env perl
use strict;
use warnings;
$ENV{SAC_DISPLAY_COPYRIGHT} = 0;

@ARGV >= 1 or die "Usage: perl $0 dirs\n";
my @dir = @ARGV;

my $ts = 0;
my $ddist = 5;
my $weight = "weight.dat";

foreach my $dir (@dir){
    chdir $dir or die "can not open $dir\n";
    print "===== $dir WEIGHT FILE =====\n";
    open(IN, "saclst dist t0 t1 t9 f *.z | sort -k2n |");
    my @lines = <IN>;
    close(IN);

    open (OUT, "> ./$weight");
    foreach my $line (@lines) {
        my ($w1, $w2, $w3, $w4, $w5) = (1, 1, 1, 1, 1);
        my ($fname, $dist, $t0, $t1, $t9) = split /\s+/, $line;
        my ($net_sta) = split /\./, $fname;
        # 震中距简化为5公里的倍数
        $dist = int($dist/$ddist + 0.5) * $ddist;

        # 如果没有手动标定到时t1，就用理论到时t0代替，如果理论到时也没有则记为0
        my $tp = 0;
        $tp = $t0 if $t0 != -12345;
        $tp = $t1 if $t1 != -12345;

        # 如果头段 t9 是标记了值的，则权重设置为0
        ($w1, $w2, $w3, $w4, $w5) = (0, 0, 0, 0, 0) if $t9 != -12345;
        printf OUT "%10s %8d %1d %1d %1d %1d %1d %5.1f %5.1f\n", $net_sta, $dist, $w1, $w2, $w3, $w4, $w5, $tp, $ts;
    }
    chdir "..";
}
