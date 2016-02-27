package DiscoverData;

use warnings;
use strict;
use Data;

#--------------------------------------------------
# Construtor
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
        nData => 0, 
        aData => undef,
        hData => undef,
        type  => "integer" # tipos inteiro ou real dos dados
        
    };

    bless $self, $class;

    $self->{aData} = ();
    $self->{hData} = ();

    return $self;
}

#--------------------------------------------------
# Insere novo arquivo em Data
# Parametro 0 = Nome do Arquivo
#-------------------------------------------------- 
sub insert {
    my $self = shift;
    my $filename = $_[0];

    if (! defined $self->{hData}->{$filename}) {
        $self->{hData}->{$filename} = new Data($filename);
        $self->{nData} += 1;
    }

    return $self->{hData}->{$filename};
}

#--------------------------------------------------
# Gera um array ordenado alfabeticamente a partir
# da hash de Data
#-------------------------------------------------- 
sub prepareArray {
    my $self = shift;
    my $filename;

    if (defined $self->{aData}) {
        undef $self->{aData};
    }

    foreach $filename (sort keys %{$self->{hData}}) {
        push(@{$self->{aData}},$self->{hData}->{$filename})
    }
}

#--------------------------------------------------
# Zera o contador de arquivos para todos os Datas
#--------------------------------------------------
sub clearCount {
    my $self = shift;
    my $data;

    foreach $data (@{$self->{aData}}) {
        $data->setCount(0);
    }
}

#--------------------------------------------------
# Incrementa em um o valor do contador de Stem
# para o arquivo escolhido
# Parametro 0 = Nome do arquivo
#--------------------------------------------------
sub incCount {
    my $self = shift;
    my $filename = $_[0];

    $self->{hData}->{$filename}->incCount();
}


#--------------------------------------------------
# Pega informacoes de Data do arquivo desejado
# Parametro 0 = Nome do Arquivo
#-------------------------------------------------- 
sub getData {
    my $self = shift;
    my $filename = $_[0];

    if (defined $self->{hData}->{$filename}) {
        return $self->{hData}->{$filename};
    }
}

#--------------------------------------------------
# Pega numero de Datas da Hash
#-------------------------------------------------- 
sub getNum {
    my $self = shift;

    return (scalar keys %{$self->{hData}});
}

#--------------------------------------------------
# Pega tipo dos dados armazenados
# 1 - inteiros (padrao)
# 2 - reais
#-------------------------------------------------- 
sub getType {
    my $self = shift;

    return $self->{type};
}

#--------------------------------------------------
# Altera o tipo dos dados armazenados
# Parametro 0 = Numero referente ao tipo
#-------------------------------------------------- 
sub setType {
    my $self = shift;
    my $n    = $_[0];

    if ($n == 1) {
        $self->{type} = "integer";
    } elsif ($n == 2) {
        $self->{type} = "real";    
    }

}

1;
