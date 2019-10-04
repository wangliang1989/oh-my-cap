# this subroutine plots waveform fits produced by source inversion srct
use strict;
use warnings;
use List::Util qw(min max);
use List::Util qw(min max);
$ENV{SAC_DISPLAY_COPYRIGHT} = 0;

sub plot {
    my ($mdl, $t1, $t2, $am, $num_com, $sec_per_inch) = @_;#model_5, 35, 70, 0.3, 5, 40
    open (IN, "< ${mdl}.out") or die "cannot open $mdl.out";
    my @result = <IN>;
    close(IN);

    # Event 20080418093658 Model model_5 FM 293 77 -15 Mw 5.08 rms 3.243e-02   121 ERR   2   4   5 ISO 0.00 0.00 CLVD 0.00 0.00
    my @result_event = split m/\s+/, shift @result;
    my $id = $result_event[1];                                          # 20080418093658
    my ($model_depth) = $result_event[3];                               # model_5
    my ($strike, $dip, $rake) = @result_event[5, 6, 7];                 # 293 77 −15
    my $mag = $result_event[9];                                         # 5.08
    my ($rms1, $rms2) = @result_event[11, 12];                          # 3.243e−02 121
    my ($err_strike, $err_dip, $err_rake) = @result_event[13, 14, 15];  # 2 4 5
    my ($iso, $iso_err) = @result_event[17, 18];                        # 0.00 0.00
    my ($clvd, $clvd_err) = @result_event[20, 21];                      # 0.00 0.00

    # # Variance reduction 69.2
    # # MomentTensor = 5.246e+16  0.771 -0.615  0.136 -0.658  0.288 -0.113
    my ($mrr, $mtt, $mff, $mrt, $mrf, $mtf);
    my $variance_reduction;
    foreach my $cmt (@result) {
        if ($cmt =~ "MomentTensor") {
            ($mrr, $mtt, $mff, $mrt, $mrf, $mtf) = (split m/\s+/, $cmt)[9, 4, 7, 6, 8, 5];
            $mrf = 0 - $mrf;
            $mtf = 0 - $mtf;
        }
        if ($cmt =~ "Variance reduction") {
            ($variance_reduction) = (split m/\s+/, $cmt)[3];
        }
    }

    # IU_WCI    137.5/-2.45 1 2.29e-04 25  5.00 1 6.50e-04 37  5.00 1 7.40e-05 90  1.60 1 9.85e-05 81  1.60 1 3.75e-04 98  3.80
    my @station;
    foreach my $line (@result) {
        push @station, $line unless ($line =~ "#");
    }

    my @polar;
    foreach (@station) {
        my ($sta) = split m/\s+/;
        my ($az, $take_off) = (split m/\s+/, `saclst az user1 f ${mdl}_${sta}.0`)[1..2];
        if ($take_off > 90) {
            $az = $az + 180;
            $take_off = 180 - $take_off;
        }
        push @polar, "$sta $az $take_off +";
    }
    unlink "gmt.history", "gmt.conf";
    system "gmt begin $mdl pdf A1c";
    my $beachball_radius = "3c";
    gmtcmd ("meca -JX5c -R-1/1/-1/1 -Sm$beachball_radius -Y1000c", "0 0 0 $mrr $mtt $mff $mrt $mrf $mtf 23 0 0");
    gmtcmd ("polar -JX5c -R-1/1/-1/1 -M$beachball_radius -D0/0 -N -Sx0.2c -Qg1p,red", @polar);
    gmtcmd ("text -JX5c -R-1/1/-1/1 -F+f10p,1,black+jLB -N -Xa2c","0 0 Event $id Model and Depth $model_depth");
    gmtcmd ("text -JX5c -R-1/1/-1/1 -F+f10p,1,black+jLB -N -Xa2c -Ya-0.5c","0 0 FM $strike $dip $rake Mw $mag rms $rms1 $rms2 ERR $err_strike $err_dip $err_rake ISO $iso $iso_err CLVD $clvd $clvd_err");
    gmtcmd ("text -JX5c -R-1/1/-1/1 -F+f10p,1,black+jLB -N -Xa2c -Ya-1c","0 0 Variance reduction $variance_reduction");

    gmtcmd ("text -JX2c -R-1/1/-1/1 -D1c/-1c -F+f15p,0,black -N -Xa3c", "0 0 Pz");
    gmtcmd ("text -JX2c -R-1/1/-1/1 -D1c/-1c -F+f15p,0,black -N -Xa7c", "0 0 Pr");
    gmtcmd ("text -JX2c -R-1/1/-1/1 -D1c/-1c -F+f15p,0,black -N -Xa11c", "0 0 Sz");
    gmtcmd ("text -JX2c -R-1/1/-1/1 -D1c/-1c -F+f15p,0,black -N -Xa15c", "0 0 Sr");
    gmtcmd ("text -JX2c -R-1/1/-1/1 -D1c/-1c -F+f15p,0,black -N -Xa19c", "0 0 Sh");

    my ($min, $max) = getminmax($mdl);

    foreach my $line (@station) {
        #IU_WCI    137.5/-2.45 1 2.29e-04 25  5.00 1 6.50e-04 37  5.00 1 7.40e-05 90  1.60 1 9.85e-05 81  1.60 1 3.75e-04 98  3.80
        my ($sta, $dist) = (split m/\s+/, $line)[0..1];
        gmtcmd ("text -JX4c -R-1/1/-1/1 -F+f10p,0,black -Y-4c","0 0.2 $sta", "0 -0.2 $dist");
        fitting("${mdl}_${sta}", $min, $max);
        my ($pz_fit, $pz_shift) = (split m/\s+/, $line)[4..5];
        my ($pr_fit, $pr_shift) = (split m/\s+/, $line)[8..9];
        my ($sz_fit, $sz_shift) = (split m/\s+/, $line)[12..13];
        my ($sr_fit, $sr_shift) = (split m/\s+/, $line)[16..17];
        my ($sh_fit, $sh_shift) = (split m/\s+/, $line)[20..21];
        label("-Xa3c", $pz_fit, $pz_shift);
        label("-Xa7c", $pr_fit, $pr_shift);
        label("-Xa11c", $sz_fit, $sz_shift);
        label("-Xa15c", $sr_fit, $sr_shift);
        label("-Xa19c", $sh_fit, $sh_shift);
    }
    system "gmt end";
}
sub label {
    my ($xy, $fit, $shift) = @_;
    gmtcmd ("text -JX2c -R-1/1/-1/1 -F+f10p,0,black -D0c/-1c -N $xy", "0 0.3 $shift", "0 -0.3 $fit");
}
sub fitting {
    my ($phase, $min, $max) = @_;
    pssac ($phase, 9, 8, "-Xa3c", $min, $max);
    pssac ($phase, 7, 6, "-Xa7c", $min, $max);
    pssac ($phase, 5, 4, "-Xa11c", $min, $max);
    pssac ($phase, 3, 2, "-Xa15c", $min, $max);
    pssac ($phase, 1, 0, "-Xa19c", $min, $max);
}
sub getminmax {
    my $mdl = shift;
    open (SAC, "| sac") or die;
    print SAC "wild echo off\n";
    print SAC "r ${mdl}_*.[0123456789]\n";
    print SAC "wh\n";
    print SAC "q\n";
    close(SAC);
    my $min;
    my $max;
    foreach (glob "${mdl}_*.?") {
        my ($mini) = (split m/\s+/, `saclst depmin f $_`)[1];
        my ($maxi) = (split m/\s+/, `saclst depmax f $_`)[1];
        $min = $mini unless (defined($min));
        $max = $maxi unless (defined($max));
        $min = min $mini, $min;
        $max = max $maxi, $max;
    }
    return ($min, $max);
}
sub pssac {
    my ($phase, $redfile, $blackfile, $x, , $min, $max) = @_;
    $redfile = "$phase.$redfile";
    $blackfile = "$phase.$blackfile";
    my ($b, $e);
    foreach ($redfile, $blackfile) {
        my ($bi, $ei) = (split m/\s+/, `saclst b e f $_`)[1..2];
        $b = $bi unless (defined($b));
        $e = $ei unless (defined($e));
        $b = min ($b, $bi);
        $e = max ($e, $ei);
    }
    $b = $b - 0.2 * ($e - $b);
    $e = $e + 0.2 * ($e - $b);
    system "gmt sac -JX4c -R$b/$e/$min/$max -En -T1 -W2p,black $x $blackfile";
    system "gmt sac -JX4c -R$b/$e/$min/$max -En -T1 -W1p,red $x $redfile";
}
sub gmtcmd {
    my @in = @_;
    my $cmd = shift @in;
    open (GMT, "| gmt $cmd") or die;
    foreach (@in) {
        print GMT "$_\n";
    }
    close(GMT);
}
1;
