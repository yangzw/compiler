#! /usr/bin/perl
use strict;
use warnings;
use 5.010;
use Key qw/get_key_code/;

my %id_table;
my $line_count = 0;
my $flag = 0;	#字符串标记
my $flag1 = 0;
open IN,"<","in.c" or die "Could not open file";
open OUT,">","token" or die "Could not open file";
while(<IN>){
	$line_count++;
	my $line = $_;
	if($line =~ /\/\*/){
		while(!($line =~ /\*\//)){
			my $in = <IN>;
			error($line_count) and last unless $in;
			$line = $line .$in;
			$line_count++;
		}
	}
	$line =~ s/\s+/ /g;
	$line =~ s/(\/\*.*\*\/)//g;
	my @list = grep {defined $_ and $_ ne /\s/} split(/\s+|(=|<|>|\/|\*|\+|\-|\(|\)|\{|\}|\[|\]|!|&&|\|\||,|;)/, $line);
	if(@list){
		my $list_ref = \@list;
	#print "@list";
	scanner($list_ref,$line_count);
}
}
close IN;
close OUT;
print "=======================\n";
print_id_table();

sub scanner{
#	print "1\n";
	my $list = shift;
	my $count = shift;
	my $length = @{$list};
#	print $length."\n";
	my $i = 0;
	while($i < $length){
		my $code =get_key_code($list->[$i]);
		if($code > -1){ #关键字
			if($list->[$i] eq "char" and $list->[$i+1] eq '*'){
				$list->[$i+1] = $list->[$i] . $list->[$i+1];
				$i++;
				$code =get_key_code($list->[$i]);
			}
			elsif($list->[$i] =~ /(\+|-|\*|\\|>|<|!|=)/){
				if($list->[$i+1] eq "="){
					$list->[$i+1] = $list->[$i] . $list->[$i+1];
					$i++;
					$code =get_key_code($list->[$i]);
				}
				elsif($list->[$i+1] eq "+" and $list->[$i] eq "+"){
					$list->[$i+1] = $list->[$i] . $list->[$i+1];
					$i++;
					$code =get_key_code($list->[$i]);
				}
				elsif($list->[$i+1] eq "-" and $list->[$i] eq "-"){
					$list->[$i+1] = $list->[$i] . $list->[$i+1];
					$i++;
					$code =get_key_code($list->[$i]);
				}

			}
			print OUT "$code $list->[$i]\n";
		}
		else{	
			if($list->[$i] =~ /^[_A-Za-z]\w*$/){#变量
				print OUT "67	$list->[$i]\n";
				handle_id($list->[$i]);
			}
			elsif($list->[$i] =~ /^'(.{0,3})'$/){#字符常量
				print OUT "53 '\n65 $1\n53 '\n";
			}
			elsif($list->[$i] =~ /^"/){#字符串常量
				my $string;
				if($list->[$i] =~ /^"(.*)"$/){
					$string = $1;
				}
				else{
					while(!($list->[$i] =~ /^"(.*)"$/)){
						error($count) and last unless $list->[$i+1];
						$list->[$i+1] = $list->[$i] . " " . $list->[$i+1];
						$i++;
					}
					$list->[$i] =~ /^"(.*)"$/;
					$string = $1;
				}
				print OUT "54 \"\n68 $string\n54 \"\n";
			}
			elsif($list->[$i] =~ /^[0-9]+$/){#整型常数
				print OUT "63 $list->[$i]\n";
			}
			elsif($list->[$i] =~ /(^[0-9]+(\.[0-9])*e?.*$)/){#实数常数
				if($list->[$i] =~ /e/){
					if($list->[$i+1] eq '-' and $list->[$i+2] =~ /^[0-9]+/){
						$list->[$i+2] = $list->[$i] . $list->[$i+1] . $list->[$i+2];
						$i+=2;
					}else{
						error($count);
					}}
				print OUT "64 $list->[$i]\n";
			}
			elsif($list->[$i] eq "true" or $list->[$i] eq "false"){#布尔常数
				print OUT "66 $list->[$i]\n";
			}
			else{
				error($count);
			}
		}
		$i++;
	}
}

sub error{
	my $count = shift;
	print "error in line $count\n";
}

sub handle_id{
#	print "2\n";
	my $id = shift;
	my $count = keys %id_table;
	$id_table{$id} = {
		id_name => $id,
		id_address => $count+1,
		id_type => undef,
		id_attrib => undef,
		id_beg => undef,
		id_end => undef,
		id_value => undef,
	};
}

sub print_id_table{
	printf "%10s %10s %10s %10s %10s %10s %10s\n",qw /id_name id_address id_type id_attrib id_beg id_end id_value/; 
	foreach my $id_name (sort keys %id_table){
		printf "%10s",$id_table{$id_name}->{id_name} // "undefined";
		printf " %10s",$id_table{$id_name}->{id_address} // "undefined";
		printf " %10s",$id_table{$id_name}->{id_type} // "undefined";
		printf " %10s",$id_table{$id_name}->{id_attrib} // "undefined";
		printf " %10s",$id_table{$id_name}->{id_beg} // "undefined";
		printf " %10s",$id_table{$id_name}->{id_end} // "undefined";
		printf " %10s\n",$id_table{$id_name}->{id_value} // "undefined";
	}
}
