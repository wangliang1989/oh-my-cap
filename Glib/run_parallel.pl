#!/usr/bin/env perl
use strict;
use warnings;
use Parallel::ForkManager;
use FindBin;
use lib $FindBin::Bin;
require config;

@ARGV >= 1 or die "Usage: perl $0 configname";
my @config = @ARGV;

# 计算当前计算机逻辑核核数
my ($MAX_PROCESSES) = split m/\n/, `cat /proc/cpuinfo |grep "processor"|wc -l`;
# 核数较少的个人 PC 只用一半的核
$MAX_PROCESSES = int ($MAX_PROCESSES * 0.5) if ($MAX_PROCESSES <= 4);
# 保证核数至少为 1
$MAX_PROCESSES = 1 if ($MAX_PROCESSES < 1);

foreach my $fname (@config){
    my %pars = read_config($fname);
    my ($model) = split m/\./, $fname;
    my $nt = $pars{"NT"};
    my $dt = $pars{"DT"};
    my @dist = split m/\s+/, $pars{"DIST"};
    my @depth = split m/\s+/, $pars{"DEPTH"};
    my $flat = "YES";
    $flat = $pars{"FLAT"} if defined($pars{"FLAT"});

    print "NT: $nt\nDT: $dt\n";
    print "MODEL:\n$pars{'MODEL'}\n";
    print "FLAT: $flat\n";
    print "DEPTH:\n@depth\n";
    print "DIST:\n@dist\n";

    my $err = 0;
    my @layer = split m/\n/, $pars{'MODEL'};
    foreach (@layer) {
        my $layer = trim($_);
        my ($dep) = split m/\s+/, $layer;
        foreach (@depth) {
            if ($_ == $dep) {
                print "设置错误：震源在 ${_}km 深度的界面上\n";
                $err++;
            }
        }
     }
    if ($err > 0) {
        print "设置有错误，将导致计算错误，OH MY CAP 中止调用 fk\n";
        next;
    }
    sleep (5);

    mkdir $model unless (-d $model);
    open (OUT, "> $model/$model") or die;
    print OUT "$pars{'MODEL'}\n";
    chdir $model or die;

    # 计算格林函数
    my $pm = Parallel::ForkManager -> new($MAX_PROCESSES);
    foreach my $depth (@depth) {
        my $pid = $pm -> start and next;

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

    chdir ".." or die;
}
