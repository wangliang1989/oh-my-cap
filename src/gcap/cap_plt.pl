# this subroutine plots waveform fits produced by source inversion srct
use strict;
use warnings;
use List::Util qw(min max);
$ENV{SAC_DISPLAY_COPYRIGHT} = 0;

my ($xa1, $xa2, $xa3, $xa4, $xa5) = ("3c", "7.1c", "11.2c", "15.3c", "19.4c");
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
        push @station, $line unless $line =~ "#";
    }

    my @polar;
    foreach (@station) {
        my ($sta) = split m/\s+/;
        my ($az, $take_off) = (split m/\s+/, `saclst az user1 f ${mdl}_${sta}.0`)[1, 2];
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
    gmtcmd ("polar -JX5c -R-1/1/-1/1 -M$beachball_radius -D0/0 -N -Sx0.4c -Qg1p,red", @polar);
    gmtcmd ("text -JX5c -R-1/1/-1/1 -F+f10p,0,black+jLB -N -Xa2c","0 0 Event $id Model and Depth $model_depth");
    gmtcmd ("text -JX5c -R-1/1/-1/1 -F+f10p,0,black+jLB -N -Xa2c -Ya-0.5c","0 0 FM $strike $dip $rake Mw $mag rms $rms1 $rms2 ERR $err_strike $err_dip $err_rake ISO $iso $iso_err CLVD $clvd $clvd_err");
    gmtcmd ("text -JX5c -R-1/1/-1/1 -F+f10p,0,black+jLB -N -Xa2c -Ya-1c","0 0 Variance reduction $variance_reduction");

    gmtcmd ("text -JX2c -R-1/1/-1/1 -D1c/-0.5c -F+f15p,0,black -N -Xa$xa1", "0 0 Pz");
    gmtcmd ("text -JX2c -R-1/1/-1/1 -D1c/-0.5c -F+f15p,0,black -N -Xa$xa2", "0 0 Pr");
    gmtcmd ("text -JX2c -R-1/1/-1/1 -D1c/-0.5c -F+f15p,0,black -N -Xa$xa3", "0 0 Sz");
    gmtcmd ("text -JX2c -R-1/1/-1/1 -D1c/-0.5c -F+f15p,0,black -N -Xa$xa4", "0 0 Sr");
    gmtcmd ("text -JX2c -R-1/1/-1/1 -D1c/-0.5c -F+f15p,0,black -N -Xa$xa5", "0 0 Sh");

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
        label("-Xa$xa1", $pz_fit, $pz_shift);
        label("-Xa$xa2", $pr_fit, $pr_shift);
        label("-Xa$xa3", $sz_fit, $sz_shift);
        label("-Xa$xa4", $sr_fit, $sr_shift);
        label("-Xa$xa5", $sh_fit, $sh_shift);
    }
    system "gmt end";
}
sub label {
    my ($xy, $fit, $shift) = @_;
    gmtcmd ("text -JX4c -R0/10/0/10 -F+f10p,0,black+jBL -N $xy", "1 1 $shift", "1 2 $fit");
}
sub fitting {
    my ($phase, $min, $max) = @_;
    pssac ($phase, 9, 8, "-Xa$xa1", $min, $max);
    pssac ($phase, 7, 6, "-Xa$xa2", $min, $max);
    pssac ($phase, 5, 4, "-Xa$xa3", $min, $max);
    pssac ($phase, 3, 2, "-Xa$xa4", $min, $max);
    pssac ($phase, 1, 0, "-Xa$xa5", $min, $max);
}
sub getminmax {
    my $mdl = shift;
    open (SAC, "| sac") or die;
    print SAC "wild echo off\n";
    print SAC "r ${mdl}_*.[0123456789]\n";
    print SAC "wh\n";
    print SAC "q\n";
    close(SAC);
    my @deps;
    foreach (glob "${mdl}_*.?") {
        my ($depmin) = (split m/\s+/, `saclst depmin f $_`)[1];
        my ($depmax) = (split m/\s+/, `saclst depmax f $_`)[1];
        push @deps, $depmin;
        push @deps, $depmax;
    }
    my $min = min @deps;
    my $max = max @deps;
    return ($min, $max);
}
sub pssac {
    my ($phase, $redfile, $blackfile, $x, $min, $max) = @_;
    $redfile = "$phase.$redfile";
    $blackfile = "$phase.$blackfile";
    my ($a) = (split m/\s+/, `saclst a f $redfile`)[1];
    my ($e1) = (split m/\s+/, `saclst e f $redfile`)[1];
    my ($e2) = (split m/\s+/, `saclst e f $blackfile`)[1];
    my $e = max $e1, $e2;
    $e = $e - $a;
    system "gmt sac -JX4c/4c -R0/$e/$min/$max -En -T+t-2 -W1.5p,black $x $blackfile";
    system "gmt sac -JX4c/4c -R0/$e/$min/$max -En -T+t-2 -W1p,red $x $redfile";
}
sub gmtcmd {
    my $cmd = shift @_;
    open (GMT, "| gmt $cmd") or die;
    print GMT "$_\n" foreach (@_);
    close(GMT);
}
1;
