#!/usr/bin/env perl
use strict;
use warnings;

sub choose_config() {
    # For cap
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

    # parse arguments of DEPTH
    $pars{"DEPTH"} = join " ", setup_values(split m/\s+/, $pars{"DEPTH"});

    # setup arguments for cap
    $pars{'cap_args'} = setup_cap_args(%pars);

    return %pars;
}
sub read_config() {
    # For fk
    my ($conf_file) = @_;

    my %pars;
    $conf_file = "$conf_file";
    %pars = config_parser($conf_file, %pars);

    # parse arguments of DIST, DEPTH
    foreach ("DIST", "DEPTH") {
        $pars{$_} = join " ", setup_values(split m/\s+/, $pars{$_});
    }

    return %pars;
}

sub setup_values() {# parse arguments of DIST FKDEPTH CAPDEPTH
    my @out;
    foreach (@_) {
        if ($_ =~ m/\//g) {
            my ($start, $end, $delta) = split m/\//;
            for (my $value = $start; $value <= $end; $value = $value + $delta) {
                push @out, $value;
            }
        } else {
            push @out, $_;
        }
    }
    @out = sort { $a <=> $b } @out;

    return @out;
}

sub setup_cap_args() {
    my (%pars) = @_;

    my $cap_args;

    my @args = keys %pars;
    foreach my $args (@args) {
        next unless ($args =~ "-");
        $cap_args .= "$args$pars{$args} ";
    }

    return $cap_args;
}

sub config_parser() {
    my ($config_file, %pars) = @_;
    open(IN," < $config_file") or die "can not open configure file $config_file\n";
    my @lines = <IN>;
    close(IN);

    foreach my $line (@lines) {
        $line = substr $line, 0, (pos $line) - 1 if ($line =~ m/#/g);
        chomp($line);
        if ($line =~ m/:/g) {
            my ($key, $value) = split ":", $line;
            next unless (defined($key) and defined($value));
            $key = trim($key);
            $value = trim($value);
            $pars{$key} = $value;
        }else{
            my ($a) = split m/\s+/, $line;
            next unless (defined($a));
            unless (defined($pars{"MODEL"})) {
                $pars{"MODEL"} = $line;
            } else {
                $pars{"MODEL"} = join "\n", ($pars{"MODEL"}, $line);
            }
        }
    }
    return %pars;
}

sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

1;
