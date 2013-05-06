package Scan;
use strict;
use base qw /Exporter/;
our @EXPORT = qw /handle/;
use 5.010;
use Key( qw / get_key_code print_id_table /);

sub handle{
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
	print OUT "\$ 0 0\n";
	close IN;
	close OUT;
	print "=======================\n";
	print_id_table();
}

sub scanner{
#	print "1\n";
	my $list = shift;
	my $count = shift;
	my $length = @{$list};
#	print $length."\n";
	my $i = 0;
	while($i < $length){
		my $code =get_key_code($list->[$i]);
		if(defined $code){ #关键字
			if($list->[$i] =~ /(\+|-|\*|\\|>|<|!|=)/){
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
			print OUT "$code $list->[$i] $count\n";
		}
		else{	
			if($list->[$i] =~ /^[_A-Za-z]\w*$/){#变量
				print OUT "ID $list->[$i] $count\n";
				handle_id($list->[$i]);
			}
			elsif($list->[$i] =~ /^'(.{0,3})'$/){#字符常量
				print OUT "' ' $count\nCHARCON $1 $count\n' ' $count\n";
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
				print OUT "\" \" $count\nSTRINGCON $string $count\n\" \" $count\n";
			}
			elsif($list->[$i] =~ /^[0-9]+$/){#整型常数
				print OUT "INTCON $list->[$i] $count\n";
			}
			elsif($list->[$i] =~ /(^[0-9]+(\.[0-9])*e?.*$)/){#实数常数
				if($list->[$i] =~ /e/){
					if($list->[$i+1] eq '-' and $list->[$i+2] =~ /^[0-9]+/){
						$list->[$i+2] = $list->[$i] . $list->[$i+1] . $list->[$i+2];
						$i+=2;
					}else{
						error($count);
					}}
				print OUT "DOUBLECON $list->[$i] $count\n";
			}
			elsif($list->[$i] eq "true" or $list->[$i] eq "false"){#布尔常数
				print OUT "BOOLCON $list->[$i] $count\n";
			}
			else{
				print OUT "0 0 $count\n";
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
	my $count = keys %Key::id_table;
	my $keyref = \%Key::id_table;
	$keyref->{$id} = {
		id_address => undef,
		id_type => undef,
		id_beg => undef,
		id_end => undef,
		id_value => undef,
	};
}
