#!/usr/bin/env perl
use strict;
use warnings;

sub read_config() {
    my ($dir) = @_;

    my %pars;
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

    # setup arguments for cap
    $pars{'cap_args'} = setup_cap_args(%pars);

    return %pars;
}

sub config_parser() {
    my ($config_file, %pars) = @_;
    open(IN," < $config_file") or die "can not open configure file $config_file\n";
    my @lines = <IN>;
    close(IN);

    foreach my $line (@lines) {
        $line = substr $line, 0, (pos $line) - 1 if ($line =~ m/#/g);
        chomp($line);
        my ($key, $value) = split ":", $line;
        next unless (defined($key) and defined($value));
        $key = trim($key);
        $value = trim($value);
        $pars{$key} = $value;
    }
    return %pars;
}

sub setup_cap_args() {
    my (%pars) = @_;

    my $cap_args;

    my @args = qw/-C -D -H -P -S -T -W -X -Z/;
    foreach my $args (@args) {
        $cap_args .= "$args$pars{$args} ";
    }

    return $cap_args;
}

sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

1;
