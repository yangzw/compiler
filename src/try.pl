#! /usr/bin/perl
use strict;
use warnings;
use 5.010;
use Key qw/get_key_code/;

open IN,"<","in.c";
while(<IN>){
	my $line = $_;
	if($line =~ /\/\*/){
		while(!($line =~ /\*\//)){
			$line = $line . <IN>;
		}
	}
	#print "a$line||\n";
	$line =~ s/\s+/ /g;
	$line =~ s/(\/\*.*\*\/)//g;
	#print $line."1\n" if $line and $line ne ' ';
	#scanner($line);
	my @list = grep {defined $_ and $_ ne /\s/} split(/\s+|(=|<|>|\/|\*|\+|\-|\(|\)|\{|\}|\[|\]|!|&&|,|;)/, $line);
	if(@list){
		print $_."#" for @list;
		print "\n";
	}
}

