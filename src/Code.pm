package Code;
use strict;
use base qw / Exporter/;
our @EXPORT = qw /handle/;
use Semanticv2;

my $coderef = \@Semanticv2::codearray;
foreach my $term (@$coderef){
	if($term eq ':='){
	}elsif($term eq '++'){
	}
}
