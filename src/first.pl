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
	print "input your terminator files:";
	chomp(my $tfile = <STDIN>);
	open INTER,"<","$tfile" or die "Could not open file";
	while(<INTER>){
		chomp;
		push @terArray, $_;
	}
	close INTER;
}
sub openNT{
	print "input your not-terminator files:";
	chomp(my $ntfile = <STDIN>);
	open INNTER,"<","$ntfile" or die "Could not open file";
	while(<INNTER>){
		chomp;
		push @ntArray, $_;
	}
	close INNTER;
}


#save the syntax production
sub openS{
	print "input your not-terminator files:";
	chomp(my $syfile = <STDIN>);
	open INSY,"<","$syfile" or die "Could not open file";
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
	#print "$x-type:$type\n";
	if($type == 1){  #终结符的first集就是它自己
		push @firstarray,$x;
		#print "here\n";
	}
	elsif($type == 2){	#非终结符
		my $productions = $production{$x};	#产生式序列数组的引用
		if(@$productions){
			for(my $j = 0; $j <= $#{$productions}; $j++){
				my $p = $productions->[$j];
				my $flag = 1;		#若一直有为产生空的，则不变
				#print "::$p\n";
				if($p eq 'eee'){
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
							push @firstarray,$first{$a[$i]}->[$k];
						}
						$i++;
					}
					#print "flag:$flag\n";
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
	foreach my $item (@keys){
		($left,$right,$anum) = split(/ /,$item);
		#print $_ for split(/ /,$item);
		#print "\n";
		$end = $$I{$item};
		$pro = $production{$left}->[$right];
		my @rights = split(' ',$pro);
		if($anum eq ($#rights+1)){		#如果是到达产生式的结尾,则跳过
			next;
		}
		$flag = 1;
		for(my $i = $anum;$i <= $#rights and $flag;$i++){	#对于点号后面的每个
			my $aafter = $rights[$i + 1];
			my $after = $rights[$i];
			#print "after:$after\n";
			$flag = 0 if((not defined $aafter) or ($first{$aafter}->[0] eq '0'));	#下下一个没有空的产生式，所以不再进行下一次循环
			for(my $j = 0; $j <= $#{$production{$after}};$j++){	#对于每一个符号的每一个产生式
				my $key = "$after $j 0";
				#print "$key\n";
				my @ends;
				if(not defined $I->{$key}){
					$I->{$key} = \@ends if not defined $I->{$key};	#假如还没有该项目，则生成
					push @keys,$key;
				}
				if(not defined $aafter){	#假如后面没有了
					for(my $j = 0 ; $j <= $#{$end};$j++){
						if(notIn($end->[$j],$I->{$key})){
							push  @{$I->{$key}},$end->[$j];
						}
					}
					#print "here is next\n";
					next;
				}
				#print "aafter:$aafter\n";
				for(my $k = 1; $k <= $#{$first{$aafter}}; $k++){	#将first集压入
					if(notIn($first{$aafter}->[$k],$I->{$key})){	#如果不在的话加入其中
						push @{$I->{$key}},$first{$aafter}->[$k];
					}
				}
			}
		}
	}
}

sub my_goto{
	my $i = shift;
	my $x = shift;
	my %j;
	foreach my $item (sort keys %$i){
		my ($left,$right,$anum) = split(/ /,$item);	#获得编号信息
		my @pro = split(' ',$production{$left}->[$right]);
		next if (not defined $pro[$anum] or $pro[$anum] ne $x);	#假如后面不是的话就不goto了
		#print "i am in\n";
		my $num = $i->{$item};		#如果是，则就创建
		$anum = $anum + 1;
		my $key = "$left $right $anum";
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
	my $key = "$b "."0 0";
	my %s;
	$s{$key} = ['$'];
	closure(\%s);
	$C[0] = \%s;
	for(my $i = 0; $i <= $#C;$i++){
		foreach(@ntArray){
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
push @left, @ntArray;
#求first集 
foreach(@left){
	find_first($_) if not defined $first{$_};
}

foreach(@left){
	my $lfirst = $first{$_};
	print "first of $_:@$lfirst\n";
}
#求items
items();
print "===The clouse is:===\n";
for(my $i = 0; $i <= $#C;$i++){
	print "$i\n";
	foreach my $name(sort keys %{$C[$i]}){
		print "$name:";
		print for @{$C[$i]->{$name}};
		print "\n";
	}
	print "===\n";
}
print "===goto===\n";
for(my $j = 0;$j <= $#goto1;$j++){
	my $go = $goto1[$j];
	foreach(sort keys %$go){
		print "$j:$_:$go->{$_}\n";
	}
}
#构造action表
createTable();
print "=====action====\n";
for(my $j = 0;$j <= $#action;$j++){
	my $actioni = $action[$j];
	foreach(sort keys %$actioni){
		print "$j:$_:$actioni->{$_}\n";
	}
}

#总控程序
sub control{
	push @stack,'0';
	open IN,"<","texst.txt" or die "Could not open:$!";
	my $s;
	while(<IN>){
		my $a = chomp;
		$s= $stack[0];
		my @next = split(" ",$action[$s]->{$a});
		if($next[0] eq '+'){			#移进
			push @stack,$a;
			push @stack,$next[1];
		}elsif($next[0] eq '-'){		#规约
			my $pro = $production{$next[1]}->[$next[2]];	#产生式
			my $num = split(' ',$pro);
			for(my $i = 0; $i < $num*2;$i++){
				pop @stack;
			}
			my $p1 = $stack[$#stack];
			my $s1 = $goto1[$p1]->{$next[1]};
			push @stack,$p1;
			push @stack,$s1;
			print "$next[1]::$pro\n";
		}elsif($next[0] eq "acc"){
			return 1;
		}else{
			error2();
		}
	}
}
