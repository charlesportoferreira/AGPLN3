package Names;

use warnings;
use strict;

#--------------------------------------------------
# Construtor
# Parametro 0 = Stem Base para este Name
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
        stem => undef,
        countFiles => 0,
        freq => 0,
        aux => 0,
        words => undef
    };

    bless $self, $class;

    $self->{words} = ();
    $self->setStem($_[0]);
    
    return $self;
}

#--------------------------------------------------
# Institui valor para o Stem
# Parametro 0 = Stem
#-------------------------------------------------- 
sub setStem {
    my $self = shift;

    $self->{stem} = $_[0];
}

#--------------------------------------------------
# Retorna valor da Stem
#-------------------------------------------------- 
sub getStem {
    my $self = shift;

    return $self->{stem};
}

#--------------------------------------------------
# Acrescenta uma palavra que foi transformada no
# Stem base desta instancia da classe Names
# Parametro 0 = Palavra
#-------------------------------------------------- 
sub insertWord {
    my $self = shift;
    my $word = $_[0];

    if (defined $self->{words}->{$word}) {
        $self->{words}->{$word} += 1;
    } else {
        $self->{words}->{$word} = 1;
    }
}

#--------------------------------------------------
# Retorna todas as palavras transformadas no Stem
# base e o numero de aparições de cada palavra 
#-------------------------------------------------- 
sub getWords {
    my $self = shift;
    my $str = "";
    my $word;

    foreach $word (sort keys %{$self->{words}}) {
        $str .= "      $word : $self->{words}->{$word}\n";
    }

    return $str;
}

#--------------------------------------------------
# Institui o valor da frequencia
# Parametro 0 = Valor da Frequencia
#-------------------------------------------------- 
sub setFreq {
    my $self = shift;
    
    $self->{freq} = $_[0];
}

#--------------------------------------------------
# Pega o valor da frequencia
#-------------------------------------------------- 
sub getFreq {
    my $self = shift;
    
    return $self->{freq};
}

#--------------------------------------------------
# Incrementa em um o valor da frequencia
#-------------------------------------------------- 
sub incFreq {
    my $self = shift;
    
    $self->{freq} += 1;
}

#--------------------------------------------------
# Institui o valor do contador de arquivos
# Parametro 0 = Valor da Contador
#-------------------------------------------------- 
sub setCount {
    my $self = shift;
    
    $self->{countFiles} = $_[0];
}

#--------------------------------------------------
# Pega o valor do contador de arquivos
#-------------------------------------------------- 
sub getCount {
    my $self = shift;
    
    return $self->{countFiles};
}

#--------------------------------------------------
# Incrementa em um o valor do contador de arquivos
#-------------------------------------------------- 
sub incCount {
    my $self = shift;
    
    $self->{countFiles} += 1;
}

#--------------------------------------------------
# Institui o valor auxiliar
# Parametro 0 = Valor auxiliar
#-------------------------------------------------- 
sub setAux {
    my $self = shift;
    
    $self->{aux} = $_[0];
}

#--------------------------------------------------
# Pega o valor auxiliar
#-------------------------------------------------- 
sub getAux {
    my $self = shift;
    
    return $self->{aux};
}

1;
