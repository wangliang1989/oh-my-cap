#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
require config;

@ARGV >= 1 or die "Usage: perl $0 configname";
my @config = @ARGV;

foreach my $fname (@config){
    my %pars = read_config($fname);
    my ($model) = split m/\./, $fname;
    my $nt = $pars{"NT"};
    my $dt = $pars{"DT"};
    my @dist = split m/\s+/, $pars{"DIST"};
    my @depth = split m/\s+/, $pars{"DEPTH"};
    my $flat = "YES";
    $flat = $pars{"FLAT"} if defined($pars{"FLAT"});

    mkdir $model unless (-d $model);
    open (OUT, "> $model/$model") or die;
    print OUT "$pars{'MODEL'}\n";
    chdir $model or die;

    print "NT: $nt\nDT: $dt\n";
    print "MODEL:\n$pars{'MODEL'}\n";
    print "FLAT: $flat\n";
    print "DEPTH:\n@depth\n";
    print "DIST:\n@dist\n";
    sleep (10);

    foreach my $depth (@depth) {
        $depth = "0$depth" if ($depth < 10);
        if ($flat eq "YES") {
            # 计算双力偶
            system "fk.pl -M$model/$depth/f -N$nt/$dt -S2 @dist";
            # 计算爆炸源
            system "fk.pl -M$model/$depth/f -N$nt/$dt -S0 @dist";
        } elsif ($flat eq "NO") {
            # 计算双力偶
            system "fk.pl -M$model/$depth -N$nt/$dt -S2 @dist";
            # 计算爆炸源
            system "fk.pl -M$model/$depth -N$nt/$dt -S0 @dist";
        } else {
            die "I don't know you want flat or not!\n";
        }
    }
    unlink glob "junk.*";

    chdir ".." or die;
}
