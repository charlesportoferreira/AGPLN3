package Data;

use warnings;
use strict;

#--------------------------------------------------
# Construtor
# Parametro 0 = Nome do Arquivo
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
        filename => undef,
        count => 0
    };

    bless $self, $class;

    $self->setFileName($_[0]);

    return $self;
}

#--------------------------------------------------
# Institui valor para o nome do arquivo
# Parametro 0 = Nome do Arquivo
#-------------------------------------------------- 
sub setFileName {
    my $self = shift;

    $self->{filename} = $_[0];
}

#--------------------------------------------------
# Pega valor do nome do arquivo
#-------------------------------------------------- 
sub getFileName {
    my $self = shift;
    
    return $self->{filename};
}

#--------------------------------------------------
# Institui valor do contador
# Parametro 0 = Valor do contador
#-------------------------------------------------- 
sub setCount {
    my $self = shift;

    $self->{count} = $_[0];
}

#--------------------------------------------------
# Pega valor do contador
#-------------------------------------------------- 
sub getCount {
    my $self = shift;

    return $self->{count};
}

#--------------------------------------------------
# Incrementa em um o valor do contador
#-------------------------------------------------- 
sub incCount {
    my $self = shift;

    $self->{count} += 1;
}

1;
