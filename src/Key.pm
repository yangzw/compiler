package Key;
use strict;
use base qw /Exporter/;
our @EXPORT = qw /get_key_code print_id_table/;
our %id_table;
our %key = (
	"id" => "ID","num" => "NUM","digit" => "DIGIT","bool" => "BOOL","int" => "INT","double" => "DOUBLE","char" => "CHAR","if" => "IF","else" => "ELSE","elseif" => "ELSEIF","for" => "FOR","while" => "WHILE","do" => "DO","continue" => "CONTINUE","break" => "BREAK","printf" => "PRINTF","scanf" => "SCANF","void" => "VOID","const" => "CONST","+" => "+","-" => "-","*" => "*","/" => "/","%" => "%","!" => "!","=" => "=",">" => "G","<" => "L","++" => "++","--" => "--","!=" => "NE",">=" => "GE","==" => "E","<=" => "LE","&&" => "&&","||" => "OR","+=" => "+=","-=" => "-=","*=" => "*=","/=" => "/=","(" => "(",")" => ")","{" => "{","}" => "}","[" => "[","]" => "]",";" => ";","," => ",","'" => "'","\"" => "\"","main"=>"MAIN","return"=>"RETURN"
);

sub get_key_code{
	my $inputkey = lc shift;
	$key{$inputkey} // undef;
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
1;
