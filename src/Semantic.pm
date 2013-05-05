package Semantic;
use strict;
use base qw /Exporter/;
our @EXPORT = qw /trans /;
use Key;
my $j = 0;
open CODE,">","code.txt";
my @ifstack;
my $step = -1;
my $flag = -1;

my $productionref = \%Key::production;
my $id_tableref = \%Key::id_table;
my $lengthref = \%Key::length;
sub trans{
	my ($right, $num ,$offset,$stackref,$valueref,$line) = @_;
	my $i = $#{$valueref};
	if($right eq 'M'){
		$offset = 0;
	}elsif($right eq 'stype'){
		unshift @$stackref,$productionref->{$right}->[$num] . ' # 1';#后面加上#1代表是普通变量
		#print "$productionref->{$right}->[$num]\n";
	}elsif($right eq 'type'){
		#print "a\n";
	}elsif($right eq 'atype'){
		my $long = $valueref->[$i-1];
		my @tmp = split(" ",shift @$stackref);
		print "long:$long type:$tmp[0]\n";
		unshift @$stackref,"$tmp[0] \$ $long";#后面加上$代表是数组变量
	}elsif($right eq 'idlist'){
		print "$valueref->[$i-1]\n";
		my $name = $valueref->[$i];
		if($id_tableref->{$name}->{id_address}){
			error("$line:变量已经声明\n");
			return -1;
		}
		$id_tableref->{$name}->{id_address} = $offset;
		my ($type,$typede,$long) = split(" ",$stackref->[0]);
		$id_tableref->{$name}->{id_type} = "$type $typede"; 
		if($typede eq '$'){
			$id_tableref->{$name}->{id_value} = $long;
		}
		$offset += $lengthref->{$type} * $long;
	}elsif($right eq 'varstat'){
		shift @$stackref;
	}elsif($right eq 'factory'){
		if($num eq '0'){
			my $name = $valueref->[$i];
			print "name:$name\n";
			if(not defined $id_tableref->{$name}->{id_address}){
				error("$line:$name:变量未声明\n");
				return -1;
			}
			if(not defined $id_tableref->{$name}->{id_defined}){
				error("$line:$name:变量未赋值\n");
				return -1;
			}
			unshift @$stackref,$name;
		}elsif($num eq '1'){
			my $value = $valueref->[$i];
			print "value:$value\n";
			my $tmp = "#tmp$j";
			$j++;
			$id_tableref->{$tmp}->{id_type} = "INT #";
			$id_tableref->{$tmp}->{id_value} = $value;
			unshift @$stackref,$tmp;
		}elsif($num eq '2'){
			my $value = $valueref->[$i];
			print "value:$value\n";
			my $tmp = "#tmp$j";
			$j++;
			$id_tableref->{$tmp}->{id_type} = "DOUBLE #";
			$id_tableref->{$tmp}->{id_value} = $value;
			unshift @$stackref,$tmp;
		}elsif($num eq '3'){
			my $id = shift @$stackref;
			print "id:$id\n";
			my $tmp;
			if(not defined $id_tableref->{$id}->{id_address}){ #是常量的情况
				$id_tableref->{$id}->{id_value} = 0 - $id_tableref->{$id}->{id_value};
				$tmp = $id;
			}else{ #不是常量
				$tmp = "#tmp$j";
				$j++;
				$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id}->{id_type};
				$id_tableref->{$tmp}->{id_address} = "-1";
				code("uminus $id : $tmp");
			}
			unshift @$stackref,$tmp;
		}elsif($num eq '4'){
		}
	}elsif($right eq 'item'){
		if($num eq '0'){
			my $id1 = shift $stackref;
			my $id2 = shift $stackref;
			my $tmp;
			if(not defined $id_tableref->{$id1}->{id_address} and not defined $id_tableref->{$id2}->{id_address}){ #是常量的情况,则直接计算
				$id_tableref->{$id1}->{id_value} = $id_tableref->{$id1}->{id_value} * $id_tableref->{$id2}->{id_value};
				$tmp = $id1;
			}
			else{
				$tmp = "#tmp$j";
				$j++;
				$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id1}->{id_type};
				$id_tableref->{$tmp}->{id_address} = "-1";
				code("* $id2 $id1 $tmp");
			}
			unshift @$stackref,$tmp;
		}elsif($num eq '1'){
			my $id1 = shift $stackref;
			my $id2 = shift $stackref;
			my $tmp;
			if(not defined $id_tableref->{$id1}->{id_address} and not defined $id_tableref->{$id2}->{id_address}){ #是常量的情况,则直接计算
				$id_tableref->{$id1}->{id_value} = $id_tableref->{$id2}->{id_value} / $id_tableref->{$id1}->{id_value};
				$tmp = $id1;
			}
			else{
				$tmp = "#tmp$j";
				$j++;
				$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id1}->{id_type};
				$id_tableref->{$tmp}->{id_address} = "-1";
				code("/ $id2 $id1 $tmp");
			}
			unshift @$stackref,$tmp;
		}elsif($num eq '2'){
		}
	}elsif($right eq 'calexp'){
		if($num eq '0'){
			my $id1 = shift $stackref;
			my $id2 = shift $stackref;
			my $tmp;
			if(not defined $id_tableref->{$id1}->{id_address} and not defined $id_tableref->{$id2}->{id_address}){ #是常量的情况,则直接计算
				$id_tableref->{$id1}->{id_value} = $id_tableref->{$id1}->{id_value} + $id_tableref->{$id2}->{id_value};
				$tmp = $id1;
			}
			else{
				$tmp = "#tmp$j";
				$j++;
				$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id1}->{id_type};
				$id_tableref->{$tmp}->{id_address} = "-1";
				code("+ $id2 $id1 $tmp");
			}
			unshift @$stackref,$tmp;
		}elsif($num eq '1'){
			my $id1 = shift $stackref;
			my $id2 = shift $stackref;
			my $tmp;
			if(not defined $id_tableref->{$id1}->{id_address} and not defined $id_tableref->{$id2}->{id_address}){ #是常量的情况,则直接计算
				$id_tableref->{$id1}->{id_value} = $id_tableref->{$id2}->{id_value} - $id_tableref->{$id1}->{id_value};
				$tmp = $id1;
			}
			else{
				$tmp = "#tmp$j";
				$j++;
				$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id1}->{id_type};
				$id_tableref->{$tmp}->{id_address} = "-1";
				code("- $id2 $id1 $tmp");
			}
			unshift @$stackref,$tmp;
		}elsif($num eq '2'){
			my $id1 = shift $stackref;
			my $id2 = shift $stackref;
			my $tmp;
			if(not defined $id_tableref->{$id1}->{id_address} and not defined $id_tableref->{$id2}->{id_address}){ #是常量的情况,则直接计算
				$id_tableref->{$id1}->{id_value} = $id_tableref->{$id1}->{id_value} % $id_tableref->{$id1}->{id_value};
				$tmp = $id1;
			}
			else{
				$tmp = "#tmp$j";
				$j++;
				$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id1}->{id_type};
				$id_tableref->{$tmp}->{id_address} = "-1";
				code("% $id2 $id1 $tmp");
			}
			unshift @$stackref,$tmp;
		}elsif($num eq '3'){
		}
	}elsif($right eq 'exp'){
	}elsif($right eq 'asstat'){
		if($num eq '0'){
			my $id = shift $stackref;
			my $value = $valueref->[$i - 2];
			print "value:$value\n";
			if(not defined $id_tableref->{$id}->{id_address}){ #是常量的情况
				$id_tableref->{$id}->{id_address} = -1;
				$id_tableref->{$value}->{id_value} = $id_tableref->{$id}->{id_value};
			}else{
				code("= $id : $value");
			}
			$id_tableref->{$value}->{id_defined} = "yes";
		}elsif($num eq '1'){
			my $id = shift $stackref;
			my $arrayel = shift $stackref;
			print "id:$id arrayel:$arrayel\n";
			if(not defined $id_tableref->{$id}->{id_address}){ #是常量的情况
				$id_tableref->{$id}->{id_address} = -1;
				$id_tableref->{$arrayel}->{id_value} = $id_tableref->{$id}->{id_value};
			}else{
				code("= $id : $arrayel");
			}
			$id_tableref->{$arrayel}->{id_defined} = "yes";
		}elsif($num eq '2'){
			my $value = $valueref->[$i - 1];
			print "value:$value";
			if(not defined $id_tableref->{$value}->{id_defined}){
				error("$line:$value not Initialization yet\n");
				return -1;
			}
			code("++ $value : $value");
		}elsif($num eq '3'){
			my $value = $valueref->[$i - 1];
			print "value:$value";
			if(not defined $id_tableref->{$value}->{id_defined}){
				error("$line:$value not Initialization yet\n");
				return -1;
			}
			code("-- $value : $value");
		}
	}elsif($right eq 'arrayelement'){
		my $position = $valueref->[$i - 1];
		my $value = $valueref->[$i - 3];
		print "value:$value position:$position\n";
		my $long = $id_tableref->{$value}->{id_value};#the lenght of array
		if($position >= $long){
			error("$line:out of limit\n");
			return -1;
		}
		my $tmp = "\$$value $position";
		if(not defined $id_tableref->{$tmp}->{id_address}){
			my ($type, undef) = split(" ",$id_tableref->{$value}->{id_type});
			my $add = $id_tableref->{$value}->{id_address} + $lengthref->{$type}*$position;
			$id_tableref->{$tmp}->{id_address} = $add;
		}
		unshift @$stackref,$tmp;
	}elsif($right eq "compare"){
		my $value = $valueref->[$i];
		print "value:$value\n";
		unshift @$stackref,$value;
	}elsif($right eq "boexp"){
		if($num eq '0'){
			unshift @$stackref,"and";
		}elsif($num eq '1'){
			unshift @$stackref,"single";
		}
	}elsif($right eq "IM"){
		$flag = 0;
		$step = 0;
	}elsif($right eq "IME"){
		$flag = -1;
		my $type = shift @$stackref;
		print "type:$type\n";
		if($type eq "single"){
			my $id2 = shift @$stackref;
			my $compare = shift @$stackref;
			my $id1 = shift @$stackref;
			code("j$compare $id1 $id2 +2");
			code("goto : : +$step");
			print "$_\n" for @ifstack;
		}elsif($type eq "and"){
			my $id22 = shift @$stackref;
			my $compare2 = shift @$stackref;
			my $id21 = shift @$stackref;
			my $id12 = shift @$stackref;
			my $compare1 = shift @$stackref;
			my $id11 = shift @$stackref;
			code("j$compare1 $id11 $id12 +2");
			my $tmp = $j + 2;
			code("goto : : +$tmp");
			code("j$compare2 $id21 $id22 +2");
			code("goto : : +$step");
			print "$_\n" for @ifstack;
		}
		$step = -1;
	}
	return $offset;
}

sub error{
	print @_;
}

sub code{
	if($step == -1){
		print CODE "@_\n";
	}else{
		push @ifstack,@_;
		$step++;
	}
}
