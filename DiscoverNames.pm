package DiscoverNames;

use warnings;
use strict;
use Names;

#--------------------------------------------------
# Construtor
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
        aNames => undef,
        hNames => undef
    };

    bless $self, $class;

    $self->{aNames} = ();
    $self->{hNames} = ();

    return $self;
}

#--------------------------------------------------
# Insere um Stem base na hash de Names com a sua
# frequencia
# Parametro 0 = Stem Base
# Parametro 1 = Frequencia do Stem
#-------------------------------------------------- 
sub insertStem {
    my $self = shift;
    my $stem = $_[0];
    my $freq = $_[1];

    if (defined $self->{hNames}->{$stem}) {
        $freq += $self->{hNames}->{$stem}->getFreq();
    } else {
        $self->{hNames}->{$stem} = new Names($stem);
    }

    $self->{hNames}->{$stem}->setFreq($freq);
}

#--------------------------------------------------
# Insere palavra referente a uma Stem da hash de
# Names
# Parametro 0 = Stem Base
# Parametro 1 = Palavra
#-------------------------------------------------- 
sub insertStemWord {
    my $self = shift;
    my $stem = $_[0];
    my $word = $_[1];

    if (! defined $self->{hNames}->{$stem}) {
        $self->{hNames}->{$stem} = new Names($stem);
    }

    $self->{hNames}->{$stem}->insertWord($word);
}

#--------------------------------------------------
# Gera um array ordenado alfabeticamente a partir
# da hash de Names
#-------------------------------------------------- 
sub prepareArrayAlph {
    my $self = shift;
    my $stem;

    if (defined $self->{aNames}) {
        undef $self->{aNames};
    }

    foreach $stem (sort keys %{$self->{hNames}}) {
        push(@{$self->{aNames}},$self->{hNames}->{$stem});
    }
}

#--------------------------------------------------
# Gera um array ordenado por frequencia a partir da
# hash de Names
#-------------------------------------------------- 
sub prepareArrayFreq {
    my $self = shift;
    my $stem;

    if (defined $self->{aNames}) {
        undef $self->{aNames};
    }

    foreach $stem (sort
        {$self->{hNames}->{$a}->getFreq() <=> $self->{hNames}->{$b}->getFreq()}
        keys %{$self->{hNames}}) {
        push(@{$self->{aNames}},$self->{hNames}->{$stem});
    }
}

#--------------------------------------------------
# Zera o contador de arquivos para todos os Names
#-------------------------------------------------- 
sub clearCount {
    my $self = shift;
    my $names;

    foreach $names (@{$self->{aNames}}) {
        $names->setCount(0);
    }
}

#--------------------------------------------------
# Incrementa em um o valor do contador de arquivos
# para o Stem escolhido
# Parametro 0 = Stem
#-------------------------------------------------- 
sub incCount {
    my $self = shift;
    my $stem = $_[0];

    $self->{hNames}->{$stem}->incCount();
}

#--------------------------------------------------
# Pega numero de Names na Hash
#-------------------------------------------------- 
sub getNum {
    my $self = shift;

    return (scalar keys %{$self->{hNames}});
}

1;
