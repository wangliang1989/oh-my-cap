#!/usr/bin/env perl
use strict;
use warnings;

my @dist;
for (my $dist = 5; $dist <= 415; $dist = $dist + 5) {
    push @dist, $dist;
}

for (my $depth = 5; $depth <= 30; $depth = $depth + 5) {
    if ($depth < 10) {
        $depth = "0$depth";
    }
    # 计算双力偶
    system "fk.pl -Mhk/$depth/k -N512/0.2 -S2 @dist\n";
    # 计算爆炸源
    system "fk.pl -Mhk/$depth/k -N512/0.2 -S0 @dist\n";
}