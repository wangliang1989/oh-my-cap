#!/usr/bin/env perl
use strict;
use warnings;
use POSIX qw(strftime);
$ENV{SAC_DISPLAY_COPYRIGHT} = 0;

@ARGV == 1 or die "Usage: perl $0 dir\n";
my ($dir) = @ARGV;

chdir $dir;

my $awk = '$1';
my @net_sta = split /\n/, `saclst dist f *.z | sort -k2n | awk '{print $awk}'`;

open (OUT, '> ./weight.dat');
foreach (@net_sta) {
    my ($net_sta) = split /\./;
    my (undef, $dist, $t0, $t1) = split /\s+/, `saclst dist t0 t1 f $_`;
    my ($w1, $w2, $w3, $w4, $w5) = (1, 1, 1, 1, 1);
    my $tp;
    my $ts = 0;
    # 震中距简化为5公里的倍数
    my $a = 0;
    my $b = 5;
    while ($dist > $b) {
        $a = $a + 5;
        $b = $b + 5;
    }
    if (($dist - $a) <= ($b - $dist)) {
        $dist = $a;
    }else{
        $dist = $b;
    }
    # 如果没有手动标定到时t1，就用理论到时t0代替
    if ($t1 == -12345) {
        $tp = $t0;
    }else{
        $tp = $t1;
    }
    
    printf OUT "%10s %8d %1d %1d %1d %1d %1d %5.1f %5.1f\n", $net_sta, $dist, $w1, $w2, $w3, $w4, $w5, $tp, $ts;
}