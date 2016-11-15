#!/usr/bin/env perl
use strict;
use warnings;
require config;

@ARGV >= 1 or die "Usage: perl $0 dirname";
my @dir = @ARGV;

my $weight = "weight.dat";# 指定权重文件
foreach my $event (@dir){
    die "no weight file\n" if !-e "$event/$weight";

    my %pars = read_config($event);
    # 获取反演的震源深度
    my @depth = split /\s+/, $pars{'DEPTH'};

    foreach my $depth (@depth) {
        $depth = "0$depth" if $depth < 10;
        my @command;
        foreach my $key (sort keys %pars) {
            # 不是反演需要的参数直接跳过
            next unless ($key =~ /^-/);

            if ($key eq '-M') {
                my ($model, $mag) = split m/\//, $pars{$key};
                push @command, "$key${model}_$depth/$mag";
            } else {
                push @command, "$key$pars{$key}";
            }
        }

        print "cap.pl @command $event\n";
        system "cap.pl @command $event";
    }
}
