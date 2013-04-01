use strict;
{
	package Num_table
	sub init1{
		my $class = shift;
		my $name = shift;
		my $self = {Name => $name, Type=>$class->default_type}
		bless $self,$class;
		$self;
	}
	sub init2{
		my $class = shift;
		my $name = shift;
		my $type = shift;
		my $self = {Name => $name, Type => $type};
		bless $self,$class;
		$self;
	}
	sub Type{
		my $self = shift;
		ref $self ? $self->{Type} : $self->default_type;
	}
	sub name{
		my $either = shift;
		ref $either ? $either->{Name} : $self->default_name;
	}
	sub default_name{' '}
	sub default_type{'int'}
}

{
	package Id_table
	sub id_name{}
	sub id_value{}
	sub id_type{}
	sub id_attrib{}
	sub id_addr{}
	sub id_begin{}
	sub id_end{}
}
1;
