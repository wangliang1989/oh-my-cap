#!/usr/bin/env perl
use strict;
use warnings;
require "$ENV{'OH_MY_CAP'}/oh-my-cap.pm";
$ENV{SAC_DISPLAY_COPYRIGHT} = 0;

@ARGV == 1 or die "Usage: perl $0 dir\n";
my ($dir) = @ARGV;
my %pars = choose_config($dir);
my ($f1, $f2, $f3, $f4) = split /\s+/, $pars{'FREQ'};

chdir $dir;

# 删除没有仪器响应的数据
foreach my $sac (glob "*.SAC") {
    my $resp = substr $sac, 0, -4;
    next unless -e "RESP.$resp";
    print "Oh My CAP: cannot find RESP.$resp\n";
    unlink $sac;
}

# 去仪器响应
open(SAC, "| sac") or die "Error in opening sac\n";
print SAC "wild echo off\n";
print SAC "r *.SAC \n";
print SAC "rglitches; rmean; rtrend; taper \n";
print SAC "trans from evalresp to vel freq $f1 $f2 $f3 $f4\n";
print SAC "mul 1e-7\n";
print SAC "w over\n";
print SAC "q\n";
close(SAC);
unlink glob "RESP.*";

chdir "..";
