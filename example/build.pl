#!/usr/bin/env perl
use strict;
use warnings;

@ARGV >= 1 or die "perl $0 origin-dir\n";
my @origin = @ARGV;

foreach my $origin (@origin) {
    open (IN, "< $origin/events.info") or die "can not open file $origin/events.info\n";
    foreach (<IN>) {
       # 收集信息
       my ($dir, $time, $evla, $evlo, $evdp, $mag) = split /\s+/;
       #20020301232107 2002-03-01T23:21:07 86.43 26.88 50.00
       # 整理事件信息
       my $seed = "$dir.seed";
       #199909200235.seed
       my $eventinfo = "$time $evla $evlo $evdp $mag";
       #yyyy-mm-ddThh:mm:ss.xxx evla evlo evdp mag
       # 复制文件、输出事件信息
       system "cp $origin/${dir}*seed $seed";
       if (-e $seed) {
           system "rm -rf $dir" if -f $dir;
           system "mkdir $dir";
           system "mv $seed $dir";
           open (OUT, "> $dir/event.info");
           print OUT "$eventinfo\n";
           close(OUT);
       }else{
           print "事件 $dir 没有找到对应的seed文件： $seed\n";
       }
    }
    close(IN);
}
