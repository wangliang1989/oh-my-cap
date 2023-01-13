#!/usr/bin/env perl
use strict;
use warnings;

system "mkdocs build -d oh-my-cap";
search_html("oh-my-cap");

sub search_html {
    my $dir = shift;
    chdir $dir or die;
    foreach my $item (glob "*") {
        search_html($item) if -d $item;
        change_img($item) if -e $item and substr($item, -4) eq 'html';
    }
    chdir '..' or die;
}
sub change_img {
    my $in = shift;
    open (IN, "< $in") or die;
    my @data = <IN>;
    close(IN);
    open (OUT, "> $in") or die;
    foreach my $info (@data) {
        $info =~ s/img\//oh-my-cap\/img\//g unless $info =~ "favicon";
        print OUT "$info";
    }
    close(OUT);
}
