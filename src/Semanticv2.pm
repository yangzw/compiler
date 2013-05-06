package Semanticv2;
use strict;
use base qw /Exporter/;
our @EXPORT = qw /trans/;
use Key;
my $j = 0;
my @codearray;
my $codecount = 0;

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
			my $id2 = shift $stackref;
			my $id1 = shift $stackref;
			my $tmp;
			if(not defined $id_tableref->{$id1}->{id_address} and not defined $id_tableref->{$id2}->{id_address}){ #是常量的情况,则直接计算
				$id_tableref->{$id1}->{id_value} = $id_tableref->{$id1}->{id_value} * $id_tableref->{$id2}->{id_value};
				$tmp = $id1;
			}
			else{
				$tmp = "#tmp$j";
				$j++;
				if(not defined $id_tableref->{$id2}->{id_address}){
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id1}->{id_type};
					code("* $id_tableref->{$id2}->{id_value} $id1 $tmp");
				}elsif(not defined $id_tableref->{$id1}->{id_address}){
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id2}->{id_type};
					code("* $id1 $id_tableref->{$id1}->{id_value} $tmp");
				}else{
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id2}->{id_type};
					code("* $id1 $id2 $tmp");
				}
				$id_tableref->{$tmp}->{id_address} = "-1";
			}
			unshift @$stackref,$tmp;
		}elsif($num eq '1'){
			my $id2 = shift $stackref;
			my $id1 = shift $stackref;
			my $tmp;
			if(not defined $id_tableref->{$id1}->{id_address} and not defined $id_tableref->{$id2}->{id_address}){ #是常量的情况,则直接计算
				$id_tableref->{$id1}->{id_value} = $id_tableref->{$id2}->{id_value} / $id_tableref->{$id1}->{id_value};
				$tmp = $id1;
			}
			else{
				$tmp = "#tmp$j";
				$j++;
				if(not defined $id_tableref->{$id2}->{id_address}){
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id1}->{id_type};
					code("/ $id_tableref->{$id2}->{id_value} $id1 $tmp");
				}elsif(not defined $id_tableref->{$id1}->{id_address}){
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id2}->{id_type};
					code("/ $id1 $id_tableref->{$id1}->{id_value} $tmp");
				}else{
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id2}->{id_type};
					code("/ $id1 $id2 $tmp");
				}
				$id_tableref->{$tmp}->{id_address} = "-1";
			}
			unshift @$stackref,$tmp;
		}elsif($num eq '2'){
		}
	}elsif($right eq 'calexp'){
		if($num eq '0'){
			my $id2 = shift $stackref;
			my $id1 = shift $stackref;
			my $tmp;
			if(not defined $id_tableref->{$id1}->{id_address} and not defined $id_tableref->{$id2}->{id_address}){ #是常量的情况,则直接计算
				$id_tableref->{$id1}->{id_value} = $id_tableref->{$id1}->{id_value} + $id_tableref->{$id2}->{id_value};
				$tmp = $id1;
			}
			else{
				$tmp = "#tmp$j";
				$j++;
				if(not defined $id_tableref->{$id2}->{id_address}){
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id1}->{id_type};
					code("+ $id_tableref->{$id2}->{id_value} $id1 $tmp");
				}elsif(not defined $id_tableref->{$id1}->{id_address}){
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id2}->{id_type};
					code("+ $id1 $id_tableref->{$id1}->{id_value} $tmp");
				}else{
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id2}->{id_type};
					code("+ $id1 $id2 $tmp");
				}
				$id_tableref->{$tmp}->{id_address} = "-1";
			}
			unshift @$stackref,$tmp;
		}elsif($num eq '1'){
			my $id2 = shift $stackref;
			my $id1 = shift $stackref;
			my $tmp;
			if(not defined $id_tableref->{$id1}->{id_address} and not defined $id_tableref->{$id2}->{id_address}){ #是常量的情况,则直接计算
				$id_tableref->{$id1}->{id_value} = $id_tableref->{$id2}->{id_value} - $id_tableref->{$id1}->{id_value};
				$tmp = $id1;
			}
			else{
				$tmp = "#tmp$j";
				$j++;
				if(not defined $id_tableref->{$id2}->{id_address}){
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id1}->{id_type};
					code("- $id_tableref->{$id2}->{id_value} $id1 $tmp");
				}elsif(not defined $id_tableref->{$id1}->{id_address}){
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id2}->{id_type};
					code("- $id1 $id_tableref->{$id1}->{id_value} $tmp");
				}else{
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id2}->{id_type};
					code("- $id1 $id2 $tmp");
				}
				$id_tableref->{$tmp}->{id_address} = "-1";
			}
			unshift @$stackref,$tmp;
		}elsif($num eq '2'){
			my $id2 = shift $stackref;
			my $id1 = shift $stackref;
			my $tmp;
			if(not defined $id_tableref->{$id1}->{id_address} and not defined $id_tableref->{$id2}->{id_address}){ #是常量的情况,则直接计算
				$id_tableref->{$id1}->{id_value} = $id_tableref->{$id1}->{id_value} % $id_tableref->{$id1}->{id_value};
				$tmp = $id1;
			}
			else{
				$tmp = "#tmp$j";
				$j++;
				if(not defined $id_tableref->{$id2}->{id_address}){
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id1}->{id_type};
					code("% $id_tableref->{$id2}->{id_value} $id1 $tmp");
				}elsif(not defined $id_tableref->{$id1}->{id_address}){
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id2}->{id_type};
					code("% $id1 $id_tableref->{$id1}->{id_value} $tmp");
				}else{
					$id_tableref->{$tmp}->{id_type} = $id_tableref->{$id2}->{id_type};
					code("% $id1 $id2 $tmp");
				}
				$id_tableref->{$tmp}->{id_address} = "-1";
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
				code("= $id_tableref->{$id}->{id_value} : $value");
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
				code("= $id_tableref->{$id}->{id_value} : $arrayel");
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
		my $value = $valueref->[$i]; print "value:$value\n";
		unshift @$stackref,$value;
	}elsif($right eq 'regexp'){
		my $id22 = shift @$stackref;
		my $compare2 = shift @$stackref;
		my $id21 = shift @$stackref;
		if(not defined $id_tableref->{$id22}->{id_address}){
			code("j$compare2 $id21 $id_tableref->{$id22}->{id_value} -");
		}else{
			code("j$compare2 $id21 $id22 -");
		}
		code("goto : : -");
	}elsif($right eq 'BE'){
		unshift @$stackref,$codecount;
		unshift @$stackref,"#";
	}elsif($right eq 'ANDM'){
		my $truegoto = $codecount - 1;
		back($truegoto,$codecount+1);
		unshift @$stackref,$codecount;#将false加入栈中
	}elsif($right eq 'ORM'){
		my $falsegoto = $codecount;
		back($falsegoto,$codecount+1);
		while(@$stackref){
			last if $stackref->[0] eq "#";
			$falsegoto = shift @$stackref;
			back($falsegoto,$codecount+1);
		}
		unshift @$stackref,$codecount-1;#将true加入堆栈中
	}elsif($right eq "boexp"){
		my $truegoto = $codecount - 1;
		back($truegoto,$codecount+1);
		if($num eq '0'){
			while(@$stackref){
				last if $stackref->[0] eq "#";
				$truegoto = shift @$stackref;
				back($truegoto,$codecount+1);
			}
		}
		unshift @$stackref,$codecount;#将false加入栈中
	}elsif($right eq 'IME'){
		while(@$stackref){
			last if $stackref->[0] eq "#";
			my $falsegoto = shift @$stackref;
			back($falsegoto,$codecount+1);
		}
		shift @$stackref;
		shift @$stackref;
	}elsif($right eq 'IMEE'){
		code("goto : : -");
		while(@$stackref){
			last if $stackref->[0] eq "#";
			my $falsegoto = shift @$stackref;
			back($falsegoto,$codecount+1);
		}
		unshift @$stackref,$codecount;
	}elsif($right eq 'WE'){
		code("goto : : -");
		while(@$stackref){
			last if $stackref->[0] eq "#";
			my $falsegoto = shift @$stackref;
			back($falsegoto,$codecount+1);
		}
		shift @$stackref;
		my $while = shift @$stackref;
		back($codecount,$while+1);
	}elsif($right eq 'wrstat'){
	     my	$value = $valueref->[$i-2];
	     code("print $value : :");
     	}elsif($right eq 'rstat'){
	     my	$value = $valueref->[$i-2];
	     $id_tableref->{$value}->{id_defined} = 'yes';
	     code("scan : : $value");
	}elsif($right eq 'program'){
		code('end');
	}
	return $offset;
}

sub error{
	print @_;
}

sub code{
	my $msg = shift;
	$codecount++;
	push @codearray,"$codecount:$msg";
	if($msg eq 'end'){
		print "i am printing code now\n";
		open CODE,">","code.txt";
		foreach(@codearray){
			print CODE "$_\n";
		}
		close CODE;
	}
}

sub back{
	my $num = shift;
	my $backnum = shift;
	my ($op,$a,$b,undef) = split(" ",$codearray[$num-1]);
	$codearray[$num-1] = "$op $a $b $backnum";
}
