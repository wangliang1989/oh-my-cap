#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
require config;
$ENV{SAC_DISPLAY_COPYRIGHT} = 0;

@ARGV == 1 or die "Usage: perl $0 dir\n";

my ($dir) = @ARGV;
my %pars = read_config($dir);
my $delta = $pars{'RESAMPLE'};

chdir $dir;

# 重采样
open(SAC, "|sac") or die "Error in opening sac\n";
foreach (glob "*.[rtz]") {
    my (undef, $delta0) = split /\s+/, `saclst delta f $_`;
    next if $delta == $delta0;  # 不需要重采样

    print SAC "r $_ \n";
    # 用interpolate实现减采样或增采样
    # 若是减采样，则需要对数据做低通滤波以防止出现混淆效应
    # 低通滤波时或许需要加上p 2以避免滤波引起的相移
    printf SAC "lp c %f\n", 0.5/$delta if $delta > $delta0;
    print SAC "interpolate delta $delta\n";
    print SAC "w over\n";
}
print SAC "q\n";
close (SAC);

chdir "..";
