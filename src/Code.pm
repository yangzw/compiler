package Code;
use strict;
use base qw / Exporter/;
our @EXPORT = qw /handlecode/;
use Key;

my $k = 0;
my @tmp;
my @labelstack;
my @codeaaray;
my $coderef;
my $id_tableref = \%Key::id_table;

sub init{
	open CODETXT,"<","code.txt";
	while(<CODETXT>){
		chomp;
		push @codeaaray,$_;
	}
	$coderef = \@codeaaray;
}

sub handlecode{
	init();
	foreach my $code(@$coderef){
		my (undef,$op,$a,$b,$des) = split(" ",$code);
		if($op eq 'goto' or $op =~ /j:/){
			if(is_in($des,\@labelstack) == -1){
				push @labelstack,$des;
			}
		}
		@labelstack = sort @labelstack;
	}
	foreach my $term (@$coderef){
		my ($line,$op,$a,$b,$des) = split(" ",$term);
		#print "$line\n";
		if($line eq $labelstack[$k]){
			print "Label$k: ";
			$k++;
		}
		if($op eq '='){
			print "mov [$id_tableref->{$des}->{id_address}] $a\n";
		}elsif($op eq '#='){
			if(is_temp($a)){
				my $i = is_in($a,\@tmp);
				print "mov ax,R$i\n";
				$tmp[$i] = '-';
			}else{
				print "mov ax,[$id_tableref->{$a}->{id_address}]\n";
			}
			print "mov [$id_tableref->{$des}->{id_address}] ax\n";
		}elsif($op eq '++'){
			print "inc [$id_tableref->{$des}->{id_address}]\n";
		}elsif($op eq '--'){
			print "dec [$id_tableref->{$des}->{id_address}]\n";
		}elsif($op eq '2+'){
			two_handle($a,$b,$des,"add");
		}elsif($op eq '1+'){
			one_handle($a,$b,$des,"add");
		}elsif($op eq '0+'){
			zero_handle($a,$b,$des,"add");
		}elsif($op eq '2-'){
			two_handle($a,$b,$des,"sub");
		}elsif($op eq '1-'){
			one_handle($a,$b,$des,"sub");
		}elsif($op eq '0-'){
			zero_handle($a,$b,$des,"sub");
		}elsif($op eq '2/'){
			two_handle($a,$b,$des,"div");
		}elsif($op eq '1/'){
			one_handle($a,$b,$des,"div");
		}elsif($op eq '0/'){
			zero_handle($a,$b,$des,"div");
		}elsif($op eq '2*'){
			two_handle($a,$b,$des,"mul");
		}elsif($op eq '1*'){
			one_handle($a,$b,$des,"mul");
		}elsif($op eq '0*'){
			zero_handle($a,$b,$des,"mul");
		}elsif($op =~ /^j/){
			print "mov ax $id_tableref->{$a}->{id_address}\n";
			print "compare ax $b\n";
			(undef,$op) = split(":",$op);
			my $jumpdes = find_des($des);
			if($op eq '>'){
				print "JG Label$jumpdes\n";
			}elsif($op eq '<'){
				print "JL Label$jumpdes\n";
			}elsif($op eq '>='){
				print "JNG Label$jumpdes\n";
			}elsif($op eq '<='){
				print "JNL Label$jumpdes\n";
			}
		}elsif($op =~ /^#j/){
			print "mov ax $id_tableref->{$a}->{id_address}\n";
			print "mov bx $id_tableref->{$b}->{id_address}\n";
			print "compare ax bx\n";
			(undef,$op) = split(":",$op);
			my $jumpdes = find_des($des);
			if($op eq '>'){
				print "JG Label$jumpdes\n";
			}elsif($op eq '<'){
				print "JL Label$jumpdes\n";
			}elsif($op eq '>='){
				print "JNG Label$jumpdes\n";
			}elsif($op eq '<='){
				print "JNL Label$jumpdes\n";
			}
		}elsif($op eq 'goto'){
			my $jumpdes = find_des($des);
			print "jum Label$jumpdes\n";
		}elsif($op eq 'end'){
			print "end\n";
		}
	}
}

sub find_des{
	my $des = shift;
	for(my $i = 0;$i <= $#labelstack;$i++){
		return $i if $des eq $labelstack[$i];
	}
	return -1;
}

sub one_handle{
	my ($a,$b,$des,$op) = @_;
	if(is_temp($b)){
		my $i = is_in($b,\@tmp);
		print "$op R$i $a\n";
		$tmp[$i] = '-';
	}else{
		print "mov ax [$id_tableref->{$b}->{id_address}]\n";
		print "$op ax $a\n";
	}
	if(is_temp($des)){
		my $i = is_in($des,\@tmp);
		if($i == -1){
			$i = findi($des);
		}
		print "mov R$i ax\n";
	}else{
		print "mov [$id_tableref->{$des}->{id_address}] ax\n";
	}
}

sub two_handle{
	my ($a,$b,$des,$op) = @_;
	if(is_temp($a)){
		my $i = is_in($a,\@tmp);
		print "$op R$i $b\n";
		$tmp[$i] = '-';
	}else{
		print "mov ax [$id_tableref->{$a}->{id_address}]\n";
		print "$op ax $b\n";
	}
	if(is_temp($des)){
		my $i = is_in($des,\@tmp);
		if($i == -1){
			$i = findi($des);
		}
		print "mov R$i ax\n";
	}else{
		print "mov [$id_tableref->{$des}->{id_address}] ax\n";
	}
}

sub zero_handle{
	my ($a,$b,$des,$op) = @_;
	my $i,
	my $j;
	if(is_temp($a)){
		$i = is_in($a,\@tmp);
		$tmp[$i] = '-';
		$i = "R$i";
	}else{
		$i = "[$id_tableref->{$a}->{id_address}]";
	}
	if(is_temp($b)){
		$j = is_in($b,\@tmp);
		$tmp[$j] = '-';
		$j = "R$j";
	}else{
		$j = "[$id_tableref->{$b}->{id_address}]";
	}
	print "mov ax $i\n";
	print "$op ax $j\n";
	if(is_temp($des)){
		my $i = is_in($des,\@tmp);
		if($i == -1){
			$i = findi($des);
		}
		print "mov R$i ax\n";
	}else{
		print "mov [$id_tableref->{$des}->{id_address}] ax\n";
	}
}

sub is_temp{
	my $a = shift;
	return 1 if $id_tableref->{$a}->{id_address} eq '-1';
	return 0;
}

sub is_in{
	my $id = shift;
	my $arrayref = shift;
	for(my $i=0;$i <= $#{$arrayref};$i++){
		return $i if $id eq $arrayref->[$i];
	}
	return -1;
}

sub findi{
	my $id = shift;
	for(my $i = 0;$i <= $#tmp;$i++){
		if($tmp[$i] eq '-'){
			$tmp[$i] = $id;
			return $i;
		}
	}
	push @tmp,$id;
	return $#tmp;
}
1;
