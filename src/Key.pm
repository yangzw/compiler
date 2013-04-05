package Key;
use strict;
use base qw /Exporter/;
our @EXPORT = qw /get_key_code/;
my %key = (
	"id" => 0,"num" => 1,"digit" => 2,"bool" => 3,"int" => 4,"double" => 5,"char" => 6,"if" => 7,"else" => 8,"elseif" => 9,"for" => 10,"while" => 11,"do" => 12,"continue" => 13,"break" => 14,"printf" => 15,"scanf" => 16,"void" => 17,"const" => 18,"+" => 19,"-" => 20,"*" => 21,"/" => 22,"%" => 23,"!" => 24,"=" => 25,">" => 26,"<" => 27,"++" => 28,"--" => 29,"!=" => 30,">=" => 31,"==" => 32,"<=" => 33,"&&" => 34,"||" => 35,"+=" => 36,"-=" => 37,"*=" => 38,"/=" => 39,"(" => 40,")" => 41,"{" => 42,"}" => 43,"[" => 44,"]" => 45,";" => 46,"," => 47,"'" => 48,"“" => 49,
);

sub get_key_code{
	my $inputkey = lc shift;
	$key{$inputkey} // -1;
}
