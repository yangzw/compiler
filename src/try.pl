#! /usr/bin/perl
use strict;
use warnings;
use 5.010;

my $a = '0cde';
my @b = split(//,$a);
my $count = split(//,$a);
print "count:$count\n";
my $k = $b[0];
print $_."\n" for @b;

my $c = 0;
my $d = "$a$c";
print "$d\n";
#$c = $c + 1;
print "$c\n";

my @e = qw /ab cd ef/;
print "$e[$k]\n";

my $n = \@b;
my $o = \@e;
print "wow\n" if $n eq $o;

my %j;
$j{'k'} = 'bl';
my $b = 'c';
$b = undef if %j;
print "fuck ad\n" if $b;

print "---\n";
for(my $i = 0; $i <= $#e;$i++){
	print $e[$i];
}
print "---\n";
