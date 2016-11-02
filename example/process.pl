#!/usr/bin/env perl
use strict;
use warnings;

@ARGV >= 1 or die "Usage: perl $0 event1 event2 ... eventn\n";

my @dir;
foreach (@ARGV) {
    if (-d $_) {
        push @dir, $_;
        next;
    }
    if (-e $_) {
        open (IN,"< $_");
        foreach (<IN>) {
            my ($dir) = split /\s+/;
            push @dir, $dir;
        }
        close(IN);
        next;
    }
    print "can not find $_ !\n";
}
foreach my $event (@dir) {
    system "perl rdseed.pl $event";
    system "perl eventinfo.pl $event";
    system "perl marktime.pl $event";
    system "perl transfer.pl $event";
    system "perl rotate.pl $event";
    system "perl resample.pl $event 0.2";
}
