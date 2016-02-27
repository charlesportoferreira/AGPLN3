package Normalize;

use strict;
use warnings;

#--------------------------------------------------
# Construtor
# Parametro 0 = Configuracoes
# Parametro 1 = Discover Table
#--------------------------------------------------
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {
        normalizeName => "None",
        config        => $_[0],
        dTable        => $_[1],
        type          => undef
    };

    bless $self,$class;

    $self->{type} = $self->{config}->getReportConfig()->{$self->{dTable}->getGram()}->{normalizeType};

    return $self;
}

#--------------------------------------------------
# Retorna nome completo da normalizacao
#-------------------------------------------------- 
sub getName {
    my $self = shift;
    my $text;

    $text = $self->{normalizeName}. " Normalize by ";
    if ($self->{type} eq "l") {
        $text .= "line";   
    } elsif ($self->{type} eq "c") {
        $text .= "column";   
    }

    return $text;
}

#--------------------------------------------------
# Escolhe metodo para normalizar
#-------------------------------------------------- 
sub run {
    my $self = shift;

    $self->{dTable}->clearCount();
    if ($self->{type} eq "l") {
        $self->runLin();   
    } elsif ($self->{type} eq "c") {
        $self->runCol();   
    }
}

#--------------------------------------------------
# Re-escrever funcoes abaixo nas classes filhas
#--------------------------------------------------

#--------------------------------------------------
# Normaliza os atributos da Discover Table p/ linha
#-------------------------------------------------- 
sub runLin {
}

#--------------------------------------------------
# Normaliza os atributos da Discover Table p/ coluna
#-------------------------------------------------- 
sub runCol {
}

1;
