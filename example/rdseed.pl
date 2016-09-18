#!/usr/bin/env perl
use strict;
use warnings;

@ARGV == 1 or die "Usage: perl $0 dir\n";
my ($dir) = @ARGV;

chdir $dir;

# 删除之前可能存在的SAC文件和RESP文件
unlink glob "*.SAC";
unlink glob "RESP*";
unlink glob "*.[rtz]";
unlink "rdseed.err_log";

# 解压seed文件
foreach my $seed (glob "*.seed") {
    system "rdseed -Rdf $seed";
}

chdir "..";
