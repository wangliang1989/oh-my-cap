#!/usr/bin/env perl
use strict;
use warnings;
require config;

@ARGV >= 1 or die "Usage: perl $0 dirname";
my @dir = @ARGV;

foreach my $event (@dir){
    my %pars = read_config($event);
    my $error = 0;
    my $i;

    # DATA PREPROCESS
    $i = $error;
    print "Checking in DATA PREPROCESS\n";
    #  FREQ
    my @freq = split m/\s+/, $pars{"FREQ"};
    unless (defined($freq[0]) and defined($freq[1]) and defined($freq[2]) and defined($freq[3])) {
        print STDERR "Error in freqlimits: no defined completely\n";
        $error++;
    } else {
        unless (($freq[0] < $freq[1]) and ($freq[1] < $freq[2]) and ($freq[2] < $freq[3])) {
            print STDERR "Error in freqlimits: the latter should be bigger: $freq[1] $freq[2] $freq[3] $freq[4]\n";
            $error++;
        }
    #  RESAMPLE
        unless (($freq[3] * $pars{"RESAMPLE"}) < 0.5) {
            print STDERR "Error in freqlimits: not obey Nyqusit law\n";
            $error++;
        }
    }
    print "FREQ is OK\n" if ($i == $error);

    # FK
    $i = $error;
    print "Checking in FK\n";
    #  FK-MODEL
    my $fname = $pars{"FKMODEL"};
    my $fkdir = "$ENV{OH_MY_CAP}/Glib";
    $fkdir = $pars{"FKDIR"} if defined($pars{"FKDIR"});
    unless (defined($fname)) {
        print STDERR "Error in FKMODEL: no defined completely\n";
        $error++;
    }
    unless (-e "$fkdir/$fname") {
        print STDERR "Error in FKMODEL: can not find file $fkdir/$fname\n";
        $error++;
    }
    my ($model) = split m/\./, $fname;
    #  NT
    my $nt = $pars{"NT"};
    unless (defined($nt)) {
        print STDERR "Error in NT: no defined NT\n";
        $error++;
    }
    #  DT
    my $dt = $pars{"DT"};
    unless (defined($dt)) {
        print STDERR "Error in NT: no defined DT\n";
        $error++;
    }
    #  DIST
    my @dist = split m/\s+/, $pars{"DIST"};
    #  FK-DEPTH
    my @fkdepth = split m/\s+/, $pars{"FKDEPTH"};
    #  FLAT
    my $flat = "YES";
    $flat = $pars{"FLAT"} if defined($pars{"FLAT"});
    print "FK is OK\n" if ($i == $error);

    # CAP
    $i = $error;
    print "Checking in CAP\n";
    #  -C
    my @filter = split m/\//, $pars{"-C"};
    unless (($freq[1] <= $filter[0]) and ($filter[1] <= $freq[2])) {
        print STDERR "filter range of Pnl does not fit the freqlimits\n";
        $error++;
    }
    unless (($freq[1] <= $filter[2]) and ($filter[3] <= $freq[2])) {
        print STDERR "filter range of Suface wave does not fit the freqlimits\n";
        $error++;
    }
    #  DT=-H
    my @capdepth = split m/\s+/, $pars{"CAPDEPTH"};
    my $green = "$ENV{OH_MY_CAP}/Glib/$pars{'CAPMODEL'}/$pars{'CAPMODEL'}";
    foreach my $grn (@capdepth) {
        my $depth = $grn;
        $depth = "0$grn" if ($depth < 10);
        my (undef, $delta) = split m/\s+/, `saclst delta f ${green}_$depth/$grn.grn.0`;
        unless ($delta == $pars{"DT"}) {
            print STDERR "DT is not equal with delta in green function in depth of $grn\n";
            $error++;
        }
        unless ($delta == $pars{"-H"}) {
            print "-H parameter is not equal with delta in green function in depth of $grn\n";
            $error++;
        }
    }
    print "CAP is OK\n" if ($i == $error);

    print "\n$error errors\n";
}
