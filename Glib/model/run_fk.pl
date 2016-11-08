#!/usr/bin/env perl
use diagnostics;
use warnings;
use strict;
use Parallel::ForkManager;

my $model = "model";
my $nt = 512;
my $dt = 0.2;
my @dist;
for (my $dist = 5; $dist <= 415; $dist = $dist + 5) {
    push @dist, $dist;
}
my $START_depth = 5;
my $MAX_depth = 30;
my $d_depth = 5;

# 计算当前计算机逻辑核核数
my $MAX_proceed = `cat /proc/cpuinfo |grep "processor"|wc -l`;
chomp(${MAX_proceed});

my @fk;
for (my $depth = $START_depth; $depth <= $MAX_depth; $depth = $depth + $d_depth) {
    $depth = "0$depth" if ($depth < 10);
    # 计算双力偶
    push @fk, "fk.pl -M$model/$depth -N$nt/$dt -S2 @dist";
    # 计算爆炸源
    push @fk, "fk.pl -M$model/$depth -N$nt/$dt -S0 @dist";
}

my $pm = Parallel::ForkManager->new($MAX_proceed);
grn_LOOP:
foreach my $fk (@fk) {
    my $pid = $pm->start and next grn_LOOP;
    system "$fk";
    $pm -> finish;
}
$pm -> wait_all_children;

unlink glob "junk.*";
