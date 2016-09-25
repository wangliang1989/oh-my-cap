#!/usr/bin/env perl
use strict;
use warnings;

my $usage = "
本脚本的作用是完成某一个目录下的地震数据的预处理\n
参数为一个或多个目录\n
";

@ARGV >= 1 or die "用法: $usage";

foreach my $event (@ARGV) {
    system "perl rdseed.pl $event";
    system "perl eventinfo.pl $event";
    system "perl marktime.pl $event";
    system "perl transfer.pl $event";
    system "perl rotate.pl $event";
    system "perl resample.pl $event 0.2";
}
