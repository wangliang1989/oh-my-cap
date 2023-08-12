#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw(min max);
require "$ENV{'PWD'}/config.pm";

@ARGV >= 1 or die "Usage: perl $0 dirname";
my @dir = @ARGV;

foreach my $event (@dir){
    my %pars = read_config($event);
    chdir $event or die;
    my @depths = split m/\s+/, $pars{'DEPTH'};
    my @info = getinfo($pars{'MODEL'}, @depths);
    my ($R) = getrange(@info);
    system "gmt begin depth_$pars{'MODEL'} pdf A1c";
    system "gmt", "basemap", "-JX10c", "-R$R", "-BWSrt", "-Bxaf+lDepth", "-Byaf+lRMS";
    foreach (@info) {
        my ($depth, $variance_reduction, $mrr, $mtt, $mff, $mrt, $mrf, $mtf) = split m/\s+/;
        gmtcmd ("meca -Sm1c", "$depth $variance_reduction 0 $mrr $mtt $mff $mrt $mrf $mtf 23 0 0");
    }
    system "gmt end";
    chdir ".." or die;
}
sub gmtcmd {
    my @in = @_;
    my $cmd = shift @in;
    open (GMT, "| gmt $cmd") or die;
    foreach (@in) {
        print GMT "$_\n";
    }
    close(GMT);
}
sub getrange {
    my @info = @_;
    my ($min_x, $max_x, $min_y, $max_y);
    foreach (@info) {
        my ($x, $y) = split m/\s+/;
        $min_x = $x unless(defined($min_x));
        $max_x = $x unless(defined($max_x));
        $min_y = $y unless(defined($min_y));
        $max_y = $y unless(defined($max_y));
        $min_x = min ($min_x, $x);
        $max_x = max ($max_x, $x);
        $min_y = min ($min_y, $y);
        $max_y = max ($max_y, $y);
    }
    $min_x = $min_x - ($max_x - $min_x) * 0.2;
    $max_x = $max_x + ($max_x - $min_x) * 0.2;
    $min_y = $min_y - ($max_y - $min_y) * 0.2;
    $max_y = $max_y + ($max_y - $min_y) * 0.2;
    return ("$min_x/$max_x/$min_y/$max_y");
}
sub getinfo {
    my $model = shift;
    my @depths = @_;
    my @out;
    foreach my $depth (@depths) {
        open (IN, "< ${model}_${depth}.out") or die "cannot open ${model}_${depth}.out";
        my @result = <IN>;
        close(IN);
        my ($mrr, $mtt, $mff, $mrt, $mrf, $mtf);
        my ($rms) = (split m/\s+/, shift @result)[11];
        foreach my $cmt (@result) {
            next unless ($cmt =~ "MomentTensor");
            ($mrr, $mtt, $mff, $mrt, $mrf, $mtf) = (split m/\s+/, $cmt)[9, 4, 7, 6, 8, 5];
            $mrf = 0 - $mrf;
            $mtf = 0 - $mtf;
        }
        push @out, "$depth $rms $mrr $mtt $mff $mrt $mrf $mtf";
    }
    return @out;
}
