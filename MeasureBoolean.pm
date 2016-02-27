package MeasureBoolean;

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
    
    $self->{measureName} = "Boolean";
    $self->{fixed} = "true";

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
    
    if ($names->getFreq() > 0) {
        $names->setFreq(1);
    } else {
        $names->setFreq(0);
    }
}

1;
