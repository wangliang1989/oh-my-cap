#!/usr/bin/env perl
use strict;
use warnings;
use Parallel::ForkManager;
require config;

@ARGV >= 1 or die "Usage: perl $0 dirname";
my @dir = @ARGV;

# 计算当前计算机逻辑核核数
my ($MAX_PROCESSES) = split m/\n/, `cat /proc/cpuinfo |grep "processor"|wc -l`;
# 核数较少的个人 PC 只用一半的核
$MAX_PROCESSES = int ($MAX_PROCESSES * 0.5) if ($MAX_PROCESSES <= 4);
# 保证核数至少为 1
$MAX_PROCESSES = 1 if ($MAX_PROCESSES < 1);

foreach my $event (@dir){
    my %pars = read_config($event);
    my $fname = $pars{"FKMODEL"};
    my ($model) = split m/\./, $fname;
    my $nt = $pars{"NT"};
    my $dt = $pars{"DT"};
    my @dist = split m/\s+/, $pars{"DIST"};
    my @depth = split m/\s+/, $pars{"FKDEPTH"};
    my $fkdir = "$ENV{OH_MY_CAP}/Glib";
    $fkdir = $pars{"FKDIR"} if defined($pars{"FKDIR"});
    my $flat = "YES";
    $flat = $pars{"FLAT"} if defined($pars{"FLAT"});

    chdir $fkdir or die;
    mkdir $model unless (-d $model);
    system "cp $fname $model/$model";
    chdir $model or die;

    # 计算格林函数
    my $pm = Parallel::ForkManager -> new($MAX_PROCESSES);
    foreach my $depth (@depth) {
        my $pid = $pm -> start and next;

        $depth = "0$depth" if ($depth < 10);
        if ($flat eq "YES") {
            # 计算双力偶
            system "fk_parallel.pl -M$model/$depth/f -N$nt/$dt -S2 @dist";
            # 计算爆炸源
            system "fk_parallel.pl -M$model/$depth/f -N$nt/$dt -S0 @dist";
        } elsif ($flat eq "NO") {
            # 计算双力偶
            system "fk_parallel.pl -M$model/$depth -N$nt/$dt -S2 @dist";
            # 计算爆炸源
            system "fk_parallel.pl -M$model/$depth -N$nt/$dt -S0 @dist";
        } else {
            die "I don't know you want flat or not!\n";
        }

        $pm -> finish;
    }
    $pm -> wait_all_children;
    unlink glob "junk.*";
}
