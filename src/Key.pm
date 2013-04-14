package Key;
use strict;
use base qw /Exporter/;
our @EXPORT = qw /get_key_code/;
my %key = (
	"id" => "ID","num" => "NUM","digit" => "DIGIT","bool" => "BOOL","int" => "INT","double" => "DOUBLE","char" => "CHAR","if" => "IF","else" => "ELSE","elseif" => "ELSEIF","for" => "FOR","while" => "WHILE","do" => "DO","continue" => "CONTINUE","break" => "BREAK","printf" => "PRINTF","scanf" => "SCANF","void" => "VOID","const" => "CONST","+" => "+","-" => "-","*" => "*","/" => "/","%" => "%","!" => "!","=" => "=",">" => "G","<" => "L","++" => "++","--" => "--","!=" => "NE",">=" => "GE","==" => "E","<=" => "LE","&&" => "&&","||" => "OR","+=" => "+=","-=" => "-=","*=" => "*=","/=" => "/=","(" => "(",")" => ")","{" => "{","}" => "}","[" => "[","]" => "]",";" => ";","," => ",","'" => "'","\"" => "\"","main"=>"MAIN","return"=>"RETURN"
);

sub get_key_code{
	my $inputkey = lc shift;
	$key{$inputkey} // undef;
}
