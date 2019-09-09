#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw(min);
use List::Util qw(max);
$ENV{SAC_DISPLAY_COPYRIGHT} = 0;

@ARGV == 1 or die "Usage: perl $0 dir\n";
my ($dir) = @ARGV;

my $taup = `which taup_time`;
exit "Skip marking arrival times in SAC files because Taup isn't install\n" unless (defined($taup));

chdir $dir;

open(SAC, "| sac") or die "Error in opening SAC\n";
print SAC "wild echo off\n";
foreach my $Zfile (glob "*Z.SAC") {
    my ($net, $sta) = split m/\./, $Zfile;
    my (undef, $evdp, $gcarc, $b, $e) = split m/\s+/, `saclst evdp gcarc b e f $Zfile`;
    # 已经有很多人报告这个脚本在这里出现非预期的结果，此脚本真的没有问题
    my @time = split m/\s+/, `taup_time -mod prem -ph P,p,Pn -h $evdp -deg $gcarc --time`;# @time 是 Pnl 波的到时
    my $t0 = min @time;# $t0 是 Pnl 波第一个波至的到时
    my $start = max ($b, ($t0 - 30));# cut 数据的开始在第一个波至前 30 秒，如果这个时刻比数据开始时刻早，则用数据本身的开始时刻
    my $end = min ($e, ($t0 + 600));# cut 数据的结束在第一个波至后 600 秒，如果这个时刻比数据结束时刻晚，则用数据本身的结束时刻

    if ($start < $end) {
        print SAC "cut $start $end\n";
        print SAC "r ${net}.${sta}.*.SAC\n";
        print SAC "ch t0 $t0\n";
        print SAC "ch kt0 Pnl\n";
        print SAC "write over\n";
    } else {
        # 如果脚本删除了此数据，最大的可能性是 event.info 中所用的时区和 sac 数据中的不同
        print "Oh My CAP: $0 unlink ${net}.${sta}.*.SAC\n";
        unlink glob "${net}.${sta}.*.SAC";
    }
}
print SAC "q\n";
close(SAC);

chdir "..";
