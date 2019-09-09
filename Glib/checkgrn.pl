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
            #110.606.grn.5
            #next unless (int($dist/5) == ($dist/5));
            open(SAC, "|sac ") or die "Error in opening sac\n";
            print SAC "wild echo off\n";
            print SAC "r $dist.grn.?\n";
            print SAC "write over\n";
            print SAC "q\n";
            close(SAC);
            my ($start, $end) = (split m/\s+/, `saclst b e f ${dist}.grn.0`)[1..2];;
            system "gmt begin";
            system "gmt figure junk pdf A1c";
            &gmt_draw($dist, $dep, $start, $end, 7, " 1c", " 0c");
            &gmt_draw($dist, $dep, $start, $end, 8, "15c", " 0c");
            &gmt_draw($dist, $dep, $start, $end, 5, " 1c", "10c");
            &gmt_draw($dist, $dep, $start, $end, 6, "15c", "10c");
            &gmt_draw($dist, $dep, $start, $end, 3, " 1c", "20c");
            &gmt_draw($dist, $dep, $start, $end, 4, "15c", "20c");
            &gmt_draw($dist, $dep, $start, $end, 0, " 1c", "30c");
            &gmt_draw($dist, $dep, $start, $end, 1, "15c", "30c");
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

sub gmt_draw () {
    my ($dist, $dep, $start, $end, $q, $locx, $locy) = @_;
    $locx = &trim($locx);
    $locy = &trim($locy);
    my ($min) = (split m/\s+/, `saclst depmin f ${dist}.grn.$q`)[1];
    my ($max) = (split m/\s+/, `saclst depmax f ${dist}.grn.$q`)[1];
    $min = $min * 1.1;
    $max = $max * 1.1;
    my ($b, $e, $t1, $t2) = (split m/\s+/, `saclst b e t1 t2 f ${dist}.grn.0`)[1..4];
    $b = max($b, ($start - 2 * ($end - $start)));
    $e = min($e, ($end + 2 * ($end - $start)));
    system "gmt sac ${dist}.grn.${q} -JX12c/6c -R$b/$e/$min/$max -Bxaf -Byaf -BWSen+t'${dist}.grn.${q}' -W1p,black -Xa$locx -Ya$locy";
    &gmtline ($start, "1p,darkblue,-", "-Xa$locx -Ya$locy -N");
    &gmtline ($end, "1p,darkblue,-", "-Xa$locx -Ya$locy -N");
    &gmtline ($t1, "1p,blue", "-Xa$locx -Ya$locy -N");
    &gmtline ($t2, "1p,red", "-Xa$locx -Ya$locy -N");
}
sub gmtline (){
    my ($t, $w, $cmd) = @_;
    open (GMT, "| gmt plot -W$w $cmd") or die;
    print GMT "$t 12345\n $t -12345\n";
    close (GMT);
}