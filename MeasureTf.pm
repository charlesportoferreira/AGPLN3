package MeasureTf;

use strict;
use warnings;

#--------------------------------------------------
# Construtor
# Parametro 0 = Numero de arquivos
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {
        measureName => "Term Frequency",
        smooth      => "disabled",
        fixed       => "false",
        type        => "integer",
        nFiles      => $_[0]
    };

    bless $self, $class;

    return $self;
}

#--------------------------------------------------
# Retorna nome da medida
#-------------------------------------------------- 
sub getName {
    my $self = shift;
    
    return $self->{measureName};
}

#--------------------------------------------------
# Retorna se existe ou nao Smooth pra essa medida
#-------------------------------------------------- 
sub hasSmooth {
    my $self = shift;
   
    if ($self->{smooth} eq "DISABLED") {
        return 0;
    } elsif ($self->{smooth} eq "ENABLED") {
        return 1;
    }
}

#--------------------------------------------------
# Retorna se e ou nao valor fixo
#-------------------------------------------------- 
sub isFixed {
    my $self = shift;
   
    if ($self->{fixed} eq "false") {
        return 0;
    } elsif ($self->{fixed} eq "true") {
        return 1;
    }
}

#--------------------------------------------------
# Retorna se e ou nao inteiro o valor das medidas
#-------------------------------------------------- 
sub isInteger {
    my $self = shift;

    if ($self->{type} eq "integer") {
        return 1;
    } elsif ($self->{type} eq "float") {
        return 0;
    }
}

#--------------------------------------------------
# Re-escrever funcoes abaixo nas classes filhas
#-------------------------------------------------- 

#--------------------------------------------------
# Funcao que retorna o valor da medida desejada
# para um determinado nome
# Parametro 0 = Nome
#-------------------------------------------------- 
sub getValue {
    my $self  = shift;
    my $names = $_[0];
    
    $names->setAux(1);
}

#--------------------------------------------------
# Funcao que retorna o valor do Smooth para quando a
# medida é igual a zero
# Parametro 0 = Nome
#-------------------------------------------------- 
sub getSmooth {
}

1;
