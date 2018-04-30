#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
require config;

@ARGV >= 1 or die "Usage: perl $0 dir\n";
my @dir = @ARGV;

foreach my $event (@dir) {
    my %pars = read_config($event);
    my $file = "$pars{'MODEL'}_depth.ps";
    chdir "$event" or die "can not open dir $event\n";
    unlink "junk.out" if (-e "junk.out");
    unlink ".gmtcommands4" if (-e ".gmtcommands4");
    unlink ".gmtdefaults4" if (-e ".gmtdefaults4");
    my @depth = sort { $a <=> $b } split m/\s+/, $pars{'DEPTH'};
    foreach my $depth (@depth) {
        system "grep -h Event $pars{'MODEL'}_${depth}.out >> junk.out";
    }

    my $i = 1;
    my $min;
    my $dof;
    my $best;
    my @dep;
    my @rms;
    my @strike;
    my @dip;
    my @rake;
    my @iso;
    my @clvd;
    my @mag;
    open(RSL, "junk.out") or die "couldn't open junk.out\n";
    my @rsl = <RSL>;
    close(RSL);
    foreach (@rsl) {
        #Event 20080418093658 Model model_05 FM 293 78 -15 Mw 5.08 rms 3.233e-02   121 ERR   2   4   5 ISO 0.00 0.00 CLVD 0.00 0.00
        my @info = split m/\s+/;
        (undef, $dep[$i]) = split m/_/, $info[3];
        ($strike[$i], $dip[$i], $rake[$i], $mag[$i], $rms[$i], $dof, $iso[$i], $clvd[$i]) = @info[5, 6, 7, 9, 11, 12, 18, 21];
        if (defined($min)) {
            if ($min > $rms[$i]) {
                $min = $rms[$i];
                $best = $i;
            }
        }else{
            $min = $rms[$i];
            $best = $i;
        }
        $i++;
    }
    if ($i == 2) {
        $dep[0] = 0;
        $rms[0] = $rms[1];
    }else{
        $dep[0] = 2 * $dep[1] - $dep[2];
        $rms[0] = $rms[2];
    }
    $dep[$i] = 2 * $dep[$i - 1] - $dep[$i - 2];
    $rms[$i] = $rms[$i - 2];
    $best++ if $best == 1 and $i > 2 and $min == $rms[2];
    my $adj = 0;
    $adj = 0.001 * $rms[$best] if $rms[$best - 1] == $rms[$best] and $rms[$best + 1] == $rms[$best];

    my $d1 = $dep[$best] - $dep[$best - 1];
    my $d2 = $dep[$best + 1] - $dep[$best];
    my $sigma = $d1 * $d2 * ($d1 + $d2) / ($d2 * ($rms[$best - 1] - $rms[$best]) + $d1 * ($rms[$best + 1] - $rms[$best]) + $adj * ($d1 + $d2));
    my $depth = 0.5 * ($rms[$best + 1] - $rms[$best - 1]) * $sigma / ($d1 + $d2);
    $min = $rms[$best] - $depth * $depth / $sigma;
    $sigma = sqrt($sigma * $min / $dof);
    $depth = $dep[$best] - $depth;
    printf "%s H %5.1f %5.1f\n", $rsl[$best - 1], $depth, $sigma;# rsl 数组是从 0 开始计数的，所以要减 1

    system "gmtset MEASURE_UNIT inch";
    open(GMT, "| psxy -JX3/1.8 -R$dep[0]/$dep[$i]/-10/100 -K -Ba50f5/a20f5WSne > $file") or die;
    for (my $x = $dep[0]; $x < $dep[$i]; $x = $x + 0.2) {
        my $y = (($x - $depth) / $sigma) ** 2;
        print GMT "$x $y\n";
    }
    close(GMT);

    open(GMT, "| psmeca -J -R -O -K -Sm2.5 >> $file") or die;
    for(my $j = 1; $j <= $i - 1; $j++) {
        my @meca = split m/\s+/, `radpttn 1 $strike[$j] $dip[$j] $rake[$j] $iso[$j] $clvd[$j] | head -1`;
        printf GMT "%6.1f %6.1f 0 %s %s %s %s %s %f 17 0 0 %s\n", $dep[$j], ($rms[$j] - $min) / ($min / $dof), @meca[6, 1, 4, 3], $meca[5], $meca[2], $mag[$j];
    }
    close(GMT);

    open(GMT, "| pstext -J -R -O >> $file") or die;
    printf GMT "%f 92 10 0 0 1 %s h=%4.1f %4.1f\n", $dep[0] + 2, $event, $depth, $sigma;
    close(GMT);

    system "ps2raster -A -E1080 -P -Tf $file";

    unlink "junk.out" if (-e "junk.out");
    unlink ".gmtcommands4" if (-e ".gmtcommands4");
    unlink ".gmtdefaults4" if (-e ".gmtdefaults4");

    chdir "..";
}
