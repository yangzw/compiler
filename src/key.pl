#! /usr/bin/perl
use strict;
use warnings;

open KEY,"<","key.txt";
while(<KEY>){
	chomp(my $name = $_);
	chomp(my $id = <KEY>);
	$name = lc $name;
	print "\"$name\" => $id,";
}
