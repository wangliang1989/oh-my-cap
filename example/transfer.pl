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

# 删除有报错的数据
# 你的数据有两个问题：1缺失一些resp文件2resp文件中缺失一些台站的信息
# 问题1可以靠代码解决，问题2目前需要自己手动删除，你把删除的代码写进脚本里，就方便了

# 解决问题2
my @exclude = ('TJ.WUQ.00', 'TJ.XZZ.00');#你把报错的台站手动填进来，perl以随意跨行
foreach my $sac (@exclude) {
    unlink glob "$sac*";
}

# 去仪器响应
open(SAC, "| sac") or die "Error in opening sac\n";
print SAC "wild echo off\n";
# 解决问题1
foreach my $sac (glob "*.SAC") {
    my $resp = substr $sac, 0, -4;
    if (-e "RESP.$resp") {
        print SAC "r $sac\n";
        print SAC "rglitches; rmean; rtrend; taper \n";
        print SAC "trans from evalresp to vel freq $f1 $f2 $f3 $f4\n";
        print SAC "mul 1e-7\n";
        print SAC "w over\n";
    }else{
        # 删除没有仪器响应文件的数据
        print "Oh My CAP: cannot find RESP.$resp\n";
        unlink $sac;
    }
}
print SAC "q\n";
close(SAC);
unlink glob "RESP.*";

chdir "..";
