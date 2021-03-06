#! /usr/bin/perl
use strict;
use warnings;

my @terArray;
my @ntArray;
my %production;
my %first;
my @goto1;
my @C;
my @action;
my @goto;
my @stack;

#read terminator and not terminator
sub openT{
	open INTER,"<","T.txt0" or die "Could not open file";
	while(<INTER>){
		chomp;
		push @terArray, $_;
	}
	close INTER;
}
sub openNT{
	open INNTER,"<","NT.txt0" or die "Could not open file";
	while(<INNTER>){
		chomp;
		push @ntArray, $_;
	}
	close INNTER;
}


#save the syntax production
sub openS{
	open INSY,"<","Syntax.txt" or die "Could not open file";
	while(<INSY>){
		chomp;
		if(/^(.*)::(.*)/)
		{
			my $left = $1;
			my @rights; 
			my $right = $2;
			$left =~ s/^ | $//g;
			$production{$left} = \@rights;
			foreach (split('\|',$right)){
				my $sright = $_;
				#$sright =~ s/<|>/ /g;
				$sright =~ s/( )+/ /g;
				$sright =~ s/^ | $//g;
				push @rights, $sright;
			}
			#print "$left=>@{$production{$left}}\n";
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
	if($type == 1){  #终结符的first集就是它自己
		push @firstarray,$x;
	}
	elsif($type == 2){	#非终结符
		my $productions = $production{$x};	#产生式序列数组的引用
		#print "in find_first:$x\n";
		if(defined @$productions){
			for(my $j = 0; $j <= $#{$productions}; $j++){
				my $p = $productions->[$j];
				my $flag = 1;		#若一直有为产生空的，则不变
				#print "::$p\"\n";
				if($p eq "eee"){
					$first{$x}->[0] = '1';	#有空的产生式
				}else{
					my @a = split(' ',$p);
					#print "a:@a\n";
					my $i = 0;
					while($flag and defined $a[$i]){
						find_first($a[$i]) if not defined $first{$a[$i]};	#如果还没有求first集,则求
						if($first{$a[$i]}->[0] eq '0'){		#如果那个元素没有产生为空的
							$flag = 0;
						}
						for(my $k = 1; $k <= $#{$first{$a[$i]}}; $k++){
							push @firstarray,$first{$a[$i]}->[$k] if notIn($first{$a[$i]}->[$k],\@firstarray);
						}
						$i++;
					}
					#print "flag:$flag\n";
					$first{$x}->[0] = '1' if $flag;
				}
				$flag = 1;
			}
		}
		else{	#若出现没有产生式的非终结符，则报错
			error("the no-terminator has not production",$x);
		}
	}
}

sub error{
	my $message = shift;
	my $x = shift;
	print "$x:$message\n";
}


sub notIn{
	my $num = shift;
	my $array = shift;
	foreach(@$array){
		return 0 if $_ eq $num;
	}
	1;
}

#求闭包
sub closure{
	my $I = shift;
	my $left;
	my $right;
	my $anum;
	my $end;
	my $pro;
	my $flag;
	my @keys = keys %$I;	#每个项目集是一个哈希表,键为其在项目的特殊编号
	#print "===============\n";
	foreach my $item (@keys){
		#	print "i am finding a closure $item\n";
		($left,$right,$anum) = split(/ /,$item);
		$end = $$I{$item};
		#print "The end is:@{$end}\n";
		$pro = $production{$left}->[$right];
		my @rights = split(' ',$pro);
		if($anum eq ($#rights+1)){		#如果是到达产生式的结尾,则跳过
			next;
		}
		$flag = 1;
		for(my $i = $anum;$i <= $#rights;$i++){	#对于点号后面的
				my $after = $rights[$i];
				last if isTer($after) == 1;	#如果后面的是终结符，则停止
				my $aafter = $rights[$i + 1];
				my @array;
				if($first{$after}->[0] eq '0'){	#下一个不能产生空
					$flag = 0;
					#下下一个无
					$flag = 2 if $i == $#rights;
				}
				if($flag == 1){
					my $b = $i + 1;
					my $akey = "$left $right $b";
					my @aends;
					#	print "afnoterm:$akey\n";
					#print "afarray:@{$I->{$akey}}\n" if defined $I->{$akey};
					if(not defined $I->{$akey}){
						$I->{$akey} = \@aends;	#假如还没有该项目，则生成
						push @keys,$akey;
						#	print "afnotterm:i am pushing now $akey\n";
					}
					for(my $k = 0; $k <= $#{$end}; $k++){	
						if(notIn($end->[$k],$I->{$akey})){
							#	print "afno-term:$end->[$k] add\n";
							push @{$I->{$akey}},$end->[$k];
						}
					}
				}
				#但下下一个不为空
				my $tmp = 0;
				if($flag == 0 or $flag == 1){
					$tmp = 2;
					#向后遍历
#					print "push first\n";
					#将first集压入
					for(my $j = $i + 1;$j <= $#rights;$j++){
						$aafter = $rights[$j];
						for(my $k = 1; $k <= $#{$first{$aafter}}; $k++){	
							push @array,$first{$aafter}->[$k];
						}
						#如果aafter没有空的产生式，则停止
						if($first{$aafter}->[0] eq '0'){
							$tmp = 0;
							last;
						}
					}
				}
				#到了最末尾,则把end集加入
				if($tmp == 2 or $flag == 2){
					#	print "add end flag:$flag\n";
					push @array,@$end;
				}
				for(my $j = 0; $j <= $#{$production{$after}};$j++){	#对于每一个符号的每一个产生式
					next if $production{$after}->[$j] eq 'eee'; #空的跳过
					my $ntkey = "$after $j 0";
					#print "$ntkey\n";
					my @ntends;
					#print "noterm:$ntkey and production:$production{$after}->[$j]\n";
					#print "array:@{$I->{$ntkey}}\n" if defined $I->{$ntkey};
					if(not defined $I->{$ntkey}){
						$I->{$ntkey} = \@ntends;	#假如还没有该项目，则生成
						push @keys,$ntkey;
						#	print "notterm:i am pushing now $ntkey\n";
					}
					for(my $k = 0; $k <= $#array; $k++){	
						if(notIn($array[$k],$I->{$ntkey})){
							#	print "no-term:$array[$k] add\n";
							push @{$I->{$ntkey}},$array[$k];
						}
					}
				}
				next if $flag == 1;
				last if $flag == 0 or $flag == 2;
		}
	}
}

sub my_goto{
	my $i = shift;
	my $x = shift;
	my %j;
	foreach my $item (sort keys %$i){
		#print "$item>>goto>>$x\n";
		my ($left,$right,$anum) = split(/ /,$item);	#获得编号信息
		my @pro = split(' ',$production{$left}->[$right]);
		next if(not defined $pro[$anum]);	#假如已经到末尾了
		my $flag = 0;
		while($pro[$anum] ne $x and $first{$pro[$anum]}->[0] eq '1'){	#假设后面的不等,但可以为空
			$anum = $anum + 1;
			last if(not defined $pro[$anum]);
			if($pro[$anum] eq $x){
				$flag = 1;
				my $key = "$left $right $anum";
				#	print "tmp:$key\n";
				my $num = $i->{$item};
				my @array;
				for(my $j = 0 ; $j <= $#{$num};$j++){
					push  @array,$num->[$j];
				}
				$j{$key} = \@array;
			}
		}
		next if ($flag == 1) or (not defined $pro[$anum]) or ($pro[$anum] ne $x);
		my $num = $i->{$item};		#如果是，则就创建
		$anum = $anum + 1;
		my $key = "$left $right $anum";
		#print "$key:i am in\n";
		my @array;
		for(my $j = 0 ; $j <= $#{$num};$j++){
			push  @array,$num->[$j];
		}
		$j{$key} = \@array;
	}
	if(%j){
		#print "here\n";
		my $jref = \%j;
		closure($jref);
		return $jref;
	}
	undef;
}

#比较两个哈希是否相同
sub istheSame{
	my $a = shift;
	my $b = shift;
	foreach my $item (sort keys %$a){
		my $anum = $a->{$item};
		my $bnum = $b->{$item};
		for(my $i = 0; $i <= $#{$anum};$i++){
			if((not defined $bnum->[$i]) or ($bnum->[$i] ne $anum->[$i])){
				return 0;
			}
		}
	}
	1;
}

#看是否已经在其中
sub isInC{
	my $item = shift;
	for(my $i = 0; $i <= $#C;$i++){
		return $i if istheSame($item,$C[$i]);
	}
	0;
}

#求项目集
sub items{
	my $b = $ntArray[0];	#第一个产生式的右部
	my $key = "$b 0 0";
	my %s;
	$s{$key} = ['$'];
	closure(\%s);
	$C[0] = \%s;
	for(my $i = 0; $i <= $#C;$i++){
		for(my $n = 1; $n <= $#ntArray;$n++){
			#print "goto:$_\n";
			my $j = my_goto($C[$i],$ntArray[$n]);
			if($j){
				if(my $k = isInC($j)){		#是否转向其他的已有
					$goto1[$i]->{$ntArray[$n]} = $k;
				}else{
					push @C,$j;
					$goto1[$i]->{$ntArray[$n]} = $#C;
				}
			}
		}
		foreach(@terArray){
			#print "goto:$_\n";
			my $j = my_goto($C[$i],$_);
			if($j){
				if(my $k = isInC($j)){		#是否转向其他的已有
					$goto1[$i]->{$_} = $k;
				}else{
					push @C,$j;
					$goto1[$i]->{$_} = $#C;
				}
			}
		}
	}
}

#构造goto和action表
sub createTable{
	my $i;
	for($i = 0;$i <= $#C;$i++){
		my $I = $C[$i];
		foreach my $item(keys $I){
			my ($left,$right,$anum) = split(/ /,$item);
			my $pro = $production{$left}->[$right];
			my $after = (split(" ",$pro))[$anum];
			#print "after:$after\n" if $after;
			if(not defined $after){		
				#print "i am in not :$item\n";
				if($left eq $ntArray[0]){		#2.c的情况
					$action[$i]->{'$'} = "acc";
				}else{					#2.b)的情况
					my $num = $I->{$item};
					foreach(@$num){
						$action[$i]->{$_} = "- $left $right";		
					}
				}
			}elsif(isTer($after) == 1){	#是终结符 2.a)的情况 
				my $j = $goto1[$i]->{$after};
				$action[$i]->{$after} = "+ $j";
			}
		}
	}
}

openT();	#打开终结符表
openNT();	#打开非终结符表
openS();	#打开语法定义表

my @left = @terArray;
#print "====ter----\n";
#print "$_\n" for @terArray;
push @left, @ntArray;
my $a = @left;
#print "the number of t and nt:$a\n";
#求first集 
foreach(@left){
	#print "first:$_\n";
	find_first($_) if not defined $first{$_};
}

open FIRST,">","first.txt";
select FIRST;
foreach(@left){
	my $lfirst = $first{$_};
	print "first of $_:@$lfirst\n";
}
select STDOUT;
close FIRST;
#求items
print "i am finding items\n";
items();
open CLOUSE,">","clouse.txt";
select CLOUSE;
print "===The clouse is:===\n";
for(my $i = 0; $i <= $#C;$i++){
	print "$i\n";
	foreach my $name(sort keys %{$C[$i]}){
		print "$name:";
		print "@{$C[$i]->{$name}}";
		print "\n";
	}
	print "===\n";
}
select STDOUT;
close CLOUSE;
print "closure write to clouse.txt\n";
open GOTO,">","goto.txt";
select GOTO;
print "===here is goto===\n";
for(my $j = 0;$j <= $#goto1;$j++){
	my $go = $goto1[$j];
	foreach(sort keys %$go){
		print "$j:$_:$go->{$_}\n";
	}
}
select STDOUT;
close GOTO;
print "goto write to goto.txt\n";
#构造action表
print "i am creating action table now\n";
createTable();
open ACTION,">","action.txt";
select ACTION;
print "=====action====\n";
for(my $j = 0;$j <= $#action;$j++){
	my $actioni = $action[$j];
	foreach(sort keys %$actioni){
		print "$j:$_:$actioni->{$_}\n";
	}
}
select STDOUT;
close ACTION;
print "action write to action.txt\n";
print "now, i am scanning\n";
my $i = control();
print "succed\n" if $i == 1;
print "failed\n" if $i == 0;

#总控程序
sub control{
	$stack[0] = '0';
	open IN,"<","token" or die "Could not open:$!";
	my $s;
	my @array;
	while(<IN>){
		chomp;
		my @a = split(" ",$_);
		push @array, @a[0,2];
	}
	close IN;
	print "control write to control.txt\n";
	open CONTROL,">","control.txt";
	select CONTROL;
	print "@array\n";
	my $i = 0;
	my $a;
	while(@array){
		$a = $array[$i];
		$s= $stack[$#stack];
		print "$a:$s\n";
		print $action[$s]->{$a} // 'undef';
		print "\n";
		last if not defined $action[$s]->{$a};
		my @next = split(" ",$action[$s]->{$a});
		#last if not defined @next;
		if($next[0] eq '+'){			#移进
			print "move in:$a $next[1]\n";
			push @stack,$a;
			push @stack,$next[1];
			$i = $i + 2;
		}elsif($next[0] eq '-'){		#规约
			print "guiyue\n";
			my $pro = $production{$next[1]}->[$next[2]];	#产生式
			my $num = split(' ',$pro);
			print "stack now:@stack..$num\n";
			for(my $i = 0; $i < $num*2;$i++){
				pop @stack;
			}
			my $p1 = $stack[$#stack];
			my $s1 = $goto1[$p1]->{$next[1]};
			print "$p1:$next[1]:$s1\n";
			push @stack,$next[1];
			push @stack,$s1;
			print "$next[1]::$pro end\n";
		}elsif($next[0] eq "acc"){
			select STDOUT;
			close CONTROL;
			return 1;
		}else{
			last;
		}
	}
	#print "stack:@stack\n";
	select STDOUT;
	close CONTROL;
	print "wrong in line $array[$i+1]\n";
	return 0;
}
