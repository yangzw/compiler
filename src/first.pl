#! /usr/bin/perl
use strict;
use warnings;

my @terArray;
my @ntArray;
my %production;
my %first;

#read terminator and not terminator
sub openT{
	open INTER,"<","T.txt1" or die "Could not open file";
	while(<INTER>){
		chomp;
		push @terArray, $_;
	}
	close INTER;
}
sub openNT{
	open INNTER,"<","NT.txt1" or die "Could not open file";
	while(<INNTER>){
		chomp;
		push @ntArray, $_;
	}
	close INNTER;
}


#save the syntax production
sub openS{
	open INSY,"<","syntax.txt1" or die "Could not open file";
	while(<INSY>){
		chomp;
		if(/^<([^>]*)>::(.*)/)
		{
			my $left = $1;
			my @rights; 
			$production{$left} = \@rights;
			my $right = $2;
			foreach (split('\|',$right)){
				my $sright = $_;
				$sright =~ s/<|>/ /g;
				$sright =~ s/ eee /eee/g;
				push @rights, $sright;
				#my @rights = split(' ',$sright);
				#print $_."\n" for @rights;
			}
		}
	}
}

#if a terminator
sub isTer{
	my $input = shift;
	if($input eq 'eee'){
		return 0;	#empty return 0
	}
	foreach (@terArray){
		return 1 if $input eq $_;	#terminator return 1
	}
	2;	#noterminator return 2
}

#某个非终结符是否可以产生空
sub canEmp{
	my $x = shift;
	my $p = $production{$x};
	foreach(@$p){
		if($_ eq 'eee'){
			return 1;
		}
	}
	0;
}

sub find_first{
	my $x = shift;
	my @firstarray;
	$firstarray[0] = '0';	#初始化第0位，表示是否有空的
	$first{$x} = \@firstarray;
	my $type = isTer($x);
	print "$x-type:$type\n";
	if($type == 1){  #终结符的first集就是它自己
		push @firstarray,$x;
		print "here\n";
	}
	elsif($type == 2){	#非终结符
		my $productions = $production{$x};	#产生式序列数组的引用
		if(@$productions){
			for(my $j = 0; $j <= $#{$productions}; $j++){
				my $p = $productions->[$j];
				my $flag = 1;		#若一直有为产生空的，则不变
				print "::$p\n";
				if($p eq 'eee'){
					$first{$x}->[0] = '1';	#有空的产生式
				}else{
					my @a = split(' ',$p);
					print "a:@a\n";
					my $i = 0;
					while($flag and defined $a[$i]){
						find_first($a[$i]) if not defined $first{$a[$i]};	#如果还没有求first集,则求
						if($first{$a[$i]}->[0] eq '0'){		#如果那个元素没有产生为空的
							$flag = 0;
						}
						for(my $k = 1; $k <= $#{$first{$a[$i]}}; $k++){
							push @firstarray,$first{$a[$i]}->[$k];
						}
						$i++;
					}
					print "flag:$flag\n";
					$first{$x}->[0] = '1' if $flag;
				}
				$flag = 1;
			}
		}
	}
	else{	#若出现没有产生式的非终结符，则报错
		error("the no-terminator has not production",$x);
	}
}

sub error{
	my $message = shift;
	my $x = shift;
	print "$x:$message\n";
}


openT();
openNT();
openS();

my @left = @terArray;
push @left, @ntArray;
foreach(@left){
	find_first($_) if not defined $first{$_};
}

foreach(@left){
	my $lfirst = $first{$_};
	print "first of $_:@$lfirst\n";
}
