package ProgressBar;

use strict;
use warnings;
use Message;

#--------------------------------------------------
# Construtor
# Parametro 0 = Configuracao
# Parametro 1 = Titulo da Barra de Progressao
# Parametro 2 = Numero de elementos
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
        config => $_[0],
        title => "",  #titulo da barra de progressao
        n => -1,      #numero de elementos
        i => -1,      #numero de elementos jah visitados
        count => 0    #contador de crecimento da barra
    };

    bless $self, $class;

    $self->{title} = $_[1];
    $self->{n} = $_[2];
    $self->{msg} = new Message($self->{config});

    return $self;
}

#--------------------------------------------------
# Inicia a Barra de Progressao imprimindo seu
# titulo
#-------------------------------------------------- 
sub StartBar {
    my $self = shift;
    my $i;

    $self->{msg}->openReportFile();
    $self->{msg}->printMsg($self->{title});
    for ($i=length($self->{title});$i<=15;$i++) {
        $self->{msg}->printMsg(" ");
    }
}

#--------------------------------------------------
# Atualiza a Barra de Progressao, crescendo
# conforme o numero de elementos.
#-------------------------------------------------- 
sub RefreshBar {
    my $self = shift;
    my $j;
    
    $self->{i}++;
   
    if ($self->{n} != 0) {
        $j = (50*$self->{i})/$self->{n};
        if ($self->{count} < int($j)) {
            until ($self->{count} == int($j)) {
                if ($self->{count} % 10 == 0) {
                    $self->{msg}->printMsg(":");
                }
                $self->{msg}->printMsg(".");
                $self->{count} += 1;
            }
        }
    }
}
 
#--------------------------------------------------
# Finaliza a Barra de Progressao chegando ao seu
# limite. 
#-------------------------------------------------- 
sub EndBar {
    my $self = shift;

    until ($self->{count} == 50) {
        if ($self->{count} % 10 == 0) {
            $self->{msg}->printMsg(":");
        }
        $self->{msg}->printMsg(".");
        $self->{count} += 1;
    }
    $self->{msg}->printMsg(": OK\n");
    
    $self->{msg}->closeReportFile();
}

1;
