package MeasureTfidf;

use strict;
use warnings;
use MeasureTf;

use vars qw(@ISA);
@ISA = qw(MeasureTf);

#--------------------------------------------------
# Construtor
# Parametro 0 = Numero de arquivos
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = $class->SUPER::new(@_);
    
    bless $self, $class;
    
    $self->{measureName} = "TF-IDF";
    $self->{smooth}      = "enabled";
    $self->{type}        = "float";
    $self->{fixed}       = "false";

    return $self;
}

#--------------------------------------------------
# Funcao que retorna o valor da medida desejada
# para um determinado nome
# Parametro 0 = Nome
#-------------------------------------------------- 
sub getValue {
    my $self  = shift;
    my $names = $_[0];
    
    $names->setAux(log($self->{nFiles}/$names->getCount())/log(10));
}

#--------------------------------------------------
# Funcao que retorna o valor do Smooth para quando
# a medida é igual a zero
# Parametro 0 = Nome
#-------------------------------------------------- 
sub getSmooth {
    my $self  = shift;
    my $names = $_[0];

    $names->setAux(log10(($self->{nFiles}*1.2)/$names->getCount()));
}

1;
