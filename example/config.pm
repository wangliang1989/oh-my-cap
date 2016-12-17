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

    # parse arguments of DEPTH
    my @depth;
    my @value = split /\s+/, $pars{"DEPTH"};
    foreach (@value) {
        if ($_ =~ m/\//g) {
            my ($start, $end, $delta) = split m/\//;
            for (my $depth = $start; $depth <= $end; $depth = $depth + $delta) {
                push @depth, $depth;
            }
        } else {
            push @depth, $_;
        }
    }
    $pars{"DEPTH"} = join " ", sort { $a <=> $b } @depth;

    # setup arguments for cap
    $pars{'cap_args'} = setup_cap_args(%pars);

    # check arguments
    my $check_errors = check_args(%pars);
    die "$check_errors errors found in event.conf\n" unless $check_errors == 0;

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

sub check_args() {
    my (%pars) = @_;
    my $error = 0;

    my @freq = split /\s+/, $pars{"FREQ"};
    my @filter = split m/\//, $pars{"-C"};

    # DATA PREPROCESS
    unless (($freq[3] * $pars{"DT"}) < 0.5) {
        print STDERR "Error in freqlimits: not obey Nyqusit law\n";
        $error++;
    }

    # Inversion
    unless (($freq[1] <= $filter[0]) and ($filter[1] <= $freq[2])) {
        print STDERR "filter range of Pnl does not fit the freqlimits\n";
        $error++;
    }
    unless (($freq[1] <= $filter[2]) and ($filter[3] <= $freq[2])) {
        print STDERR "filter range of Suface wave does not fit the freqlimits\n";
        $error++;
    }

    my @depth = split /\s+/, $pars{"DEPTH"};
    my $green = "$ENV{OH_MY_CAP}/Glib/$pars{'MODEL'}/$pars{'MODEL'}";
    foreach my $grn (@depth) {
        my $depth = $grn;
        $depth = "0$grn" if ($depth < 10);
        my (undef, $delta) = split /\s+/, `saclst delta f ${green}_$depth/$grn.grn.0`;
        unless ($delta == $pars{"DT"}) {
            print STDERR "DT is not equal with delta in green function in depth of $grn\n";
            $error++;
        }
        unless ($delta == $pars{"-H"}) {
            print "-H parameter is not equal with delta in green function in depth of $grn\n";
            $error++;
        }
    }

    return ($error);
}

sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

1;
