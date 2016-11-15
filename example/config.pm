#!/usr/bin/env perl
use strict;
use warnings;

sub read_config() {
    my ($dir) = @_;

    my %pars;
    my $par_id = 0;
    my $conf_file;

    # 1st: project-wide configure file
    $conf_file = "$ENV{OH_MY_CAP}/event.conf";
    %pars = config_parser($conf_file, %pars) if -e $conf_file;

    # 2nd: configure file in current directory
    $conf_file = "./event.conf";
    %pars = config_parser($conf_file, %pars) if -e $conf_file;

    # 3rd: event-based configure file
    $conf_file = "$dir/event.conf";
    %pars = config_parser($conf_file, %pars) if -e $conf_file;

    # check if all pars are valid
    check_pars(%pars);

    return %pars;
}

sub check_pars() {
    my (%pars) = @_;

    while (my ($key, $value) = each (%pars)) {
        print "$key $value\n";
    }
    return 0;
}

sub config_parser() {
    my ($config_file, %pars) = @_;
    open(IN," < $config_file") or die "can not open configure file $config_file\n";
    my @lines = <IN>;
    close(IN);

    foreach my $line (@lines) {
        next if $line =~ /^#/;
        chomp($line);
        my ($key, $value) = split ":", $line;
        $pars{$key} = $value;
    }
    return %pars;
}

1;
