#!/usr/bin/env perl
use strict;
use warnings;
$ENV{SAC_DISPLAY_COPYRIGHT}=0;
use List::Util qw(min max);
use FindBin;
use lib $FindBin::Bin;
require config;

my @config = @ARGV;
foreach my $fname (@config) {
    die "$fname not exist" unless (-e $fname);
    my %pars = read_config($fname);
    my ($model) = split m/\./, $fname;
    my @evdp = split m/\s+/, $pars{"DEPTH"};
    my @dist = split m/\s+/, $pars{"DIST"};

    chdir $model or die;
    foreach my $dep (@evdp) {
        my @cpdf;
        chdir "${model}_$dep" or die;
        print "${model}_$dep\n";
        foreach my $dist (@dist) {
            &refresh_sac_headers($dist);
            system "gmt begin junk pdf A1c";
            system "gmt subplot begin 3x4 -Fs8c/4c -M0.5c/1c -T'Green Functions of $dist km'";
            foreach my $q (0, 1, 2, 3, 4, 5, 6, 7, 8, 'a', 'b', 'c') {
                my $num = $q;
                $num = 9 if ($q eq 'a');
                $num = 10 if ($q eq 'b');
                $num = 11 if ($q eq 'c');
                &gmt_draw($dist, $q, $num);
            }
            system "gmt subplot end";
            system "gmt end";
            system "mv junk.pdf ${dist}.pdf";
            push @cpdf, "${dist}.pdf";
        }
        system "cpdf @cpdf -o ../${model}_${dep}.pdf";
        unlink glob "*_*.pdf";
        chdir ".." or die;
    }
    chdir ".." or die;
}

sub refresh_sac_headers () {
    my ($dist) = @_;
    open(SAC, "|sac ") or die "Error in opening sac\n";
    print SAC "wild echo off\n";
    print SAC "r $dist.grn.?\n";
    print SAC "wh\n";
    print SAC "q\n";
    close(SAC);
}
sub gmt_draw () {
    my ($dist, $q, $num) = @_;
    my ($b, $e, $min, $max, $t1, $t2) = &getrange($dist, $q);
    system "gmt subplot set $num";
    system "gmt basemap -R$b/$e/$min/$max -Baf -BWSen+t'${dist}.grn.${q}'";
    system "gmt sac  -W1p,black ${dist}.grn.${q}";
    &gmtline ($t1, "1p,blue", $min, $max);
    &gmtline ($t2, "1p,red", $min, $max);
}
sub getrange () {
    my ($dist, $q) = @_;
    my ($b, $e, $t1, $t2) = (split m/\s+/, `saclst b e t1 t2 f ${dist}.grn.$q`)[1..4];
    my ($min) = (split m/\s+/, `saclst depmin f ${dist}.grn.$q`)[1];
    my ($max) = (split m/\s+/, `saclst depmax f ${dist}.grn.$q`)[1];
    $min = $min * 1.1;
    $max = $max * 1.1;
    if (($min == 0) and ($max == 0)) {
        $min = -1;
        $max = 1;
    }
    return ($b, $e, $min, $max, $t1, $t2);
}
sub gmtline (){
    my ($t, $w, $min, $max) = @_;
    open (GMT, "| gmt plot -W$w") or die;
    print GMT "$t $min\n $t $max\n";
    close (GMT);
}