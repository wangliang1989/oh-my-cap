#!/usr/bin/env perl
use strict;
use warnings;
use POSIX qw(strftime);
$ENV{SAC_DISPLAY_COPYRIGHT} = 0;

@ARGV == 1 or die "Usage: perl $0 dir\n";
my ($dir) = @ARGV;

chdir $dir or die "cannot get in $dir";

open(INFO, "< event.info") or die "Cannot find event info.";
my $eventinfo = <INFO>;
my ($origin, $evla, $evlo, $evdp, $mag) = split " ", $eventinfo;
close(INFO);

# 对发震时刻做解析
my ($date, $time) = split "T", $origin;
my ($year, $month, $day) = split "-", $date;
my ($hour, $minute, $second) = split ":", $time;
# 秒和毫秒均为整数
my ($sec, $msec) = split /\./, $second;
$msec = int(($second - $sec) * 1000 + 0.5);

# 计算发震日期是一年中的第几天
my $jday = strftime("%j", $second, $minute, $hour, $day, $month-1, $year-1900);

open(SAC, "| sac") or die "Error in opening SAC\n";
print SAC "wild echo off\n";
print SAC "r *.SAC\n";
print SAC "synchronize\n";  # 同步所有文件的参考时刻
print SAC "ch o gmt $year $jday $hour $minute $sec $msec\n";
print SAC "ch allt (0 - &1,o&) iztype IO\n";
print SAC "ch evlo $evlo evla $evla evdp $evdp\n";
print SAC "ch mag $mag\n" if defined $mag;
print SAC "wh\n";
print SAC "q\n";
close(SAC);

chdir "..";
