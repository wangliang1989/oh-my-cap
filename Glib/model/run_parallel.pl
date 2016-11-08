#!/usr/bin/env perl
use diagnostics;
use warnings;
use strict;
use Parallel::ForkManager;

my $model = "model";
my $nt = 512;
my $dt = 0.2;

my $depth_start = 5;
my $depth_end = 30;
my $depth_step = 5;

my $dist_start = 5;
my $dist_end = 415;
my $dist_step = 5;
my @dist;
for (my $dist = $dist_start; $dist <= $dist_end; $dist = $dist + $dist_step) {
    push @dist, $dist;
}

# 计算当前计算机逻辑核核数
my ($MAX_PROCESSES) = split /\n/, `cat /proc/cpuinfo |grep "processor"|wc -l`;

# 计算格林函数
my $pm = Parallel::ForkManager -> new($MAX_PROCESSES);
for (my $depth = $depth_start; $depth <= $depth_end; $depth = $depth + $depth_step) {
    my $pid = $pm -> start and next;
    $depth = "0$depth" if ($depth < 10);
    # 双力偶
    system "fk_parallel.pl -M$model/$depth -N$nt/$dt -S2 @dist";
    # 爆炸源
    system "fk_parallel.pl -M$model/$depth -N$nt/$dt -S0 @dist";
    $pm -> finish;
}
$pm -> wait_all_children;

unlink glob "junk.*";
