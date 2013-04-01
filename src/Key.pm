package Key;
use strict;
use base qw /Exporter/;
our @EXPORT = qw /get_key_code/;
my %key = (
	"char*" => 1,"break" => 2,"case" => 3,"char" => 4,"const" => 5,"continue" => 6,"default" => 7,"do" => 8,"double" => 9,"else" => 10,"enum" => 11,"extern" => 12,"float" => 13,"for" => 14,"goto" => 15,"if" => 16,"int" => 17,"long" => 18,"register" => 19,"return" => 20,"short" => 21,"signed" => 22,"sizeof" => 23,"static" => 24,"struct" => 25,"switch" => 26,"typedef" => 27,"--" => 28,"unsigned" => 29,"void" => 30,"++" => 31,"while" => 32,"+" => 33,"-" => 34,"*" => 35,"/" => 36,"&&" => 37,"||" => 38,"+=" => 39,"-=" => 40,"*=" => 41,"/=" => 42,"=" => 43,">=" => 44,"<=" => 45,">" => 46,"<" => 47,"{" => 48,"}" => 49,"." => 50,"," => 51,";" => 52,"'" => 53,"\"" => 54,"/*" => 55,"*/" => 56,"(" => 57,")" => 58,"[" => 59,"]" => 60,"==" => 61,"!=" => 62,
);

sub get_key_code{
	my $inputkey = lc shift;
	$key{$inputkey} // -1;
}
