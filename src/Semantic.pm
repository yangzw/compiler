package Semantic;
use strict;
use base qw /Exporter/;
our @EXPORT = qw /trans /;
use Key;

my $productionref = \%Key::production;
my $id_tableref = \%Key::id_table;
sub trans{
	my ($right, $num ,$offset,$stackref,$valueref) = @_;
	if($right eq 'M'){
		$offset = 0;
	}
	return $offset;
}
