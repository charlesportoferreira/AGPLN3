package Cuts;

use warnings;
use strict;
use Message;

#--------------------------------------------------
# Construtor
# Parametro 0 = Configuracoes
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {
        config => $_[0]
    };
    
    bless $self, $class;
    
    return $self;
}

#--------------------------------------------------
# Define pontos inferior e superior de corte por
# ranking
# Parametro 0 = Multiplicador
# Parametro 1 = DiscoverTable
#-------------------------------------------------- 
sub rankStdDev {
    my $self = shift;
    my $mult = $_[0];
    my $dTable = $_[1];
    my $msg = new Message($self->{config});
    my ($stem,$aux,$n,$soma,$somaq);
    my ($stdDev,$mean);
    my ($max,$min,$maxFreq,$minFreq);
    my (@aFreq,@aRank);

    foreach $stem (@{$dTable->{DNames}->{aNames}}) {
        $aux = $stem->getFreq();
        if (!defined $aFreq[$aux]) {
            $aFreq[$aux] = $aux;
        }
    }
    
    $soma = 0;
    $somaq = 0;
    $n = 1;
    
    #supondo o exemplo de limites [3,9], assim a maxFreq sera 10
    $maxFreq = scalar @aFreq; 

    for ($aux=$maxFreq;$aux>0;$aux--) {
        if (defined $aFreq[$aux]) {
            push(@aRank,$aux);
            $soma += $n;
            $somaq += $n*$n;
            $n++;
        }
    }

    $n--;

    $stdDev = sqrt(($somaq - ($soma*$soma)/$n)/($n-1));
    $mean = $soma/$n;
    $max = int($mean + $mult*$stdDev);
    $min = int($mean - $mult*$stdDev);
    if ($min < 0) {
        $min = 0;
    }
    if ($max > (scalar @aRank)-1) {
        $max = (scalar @aRank)-1;
    }
    
    # Supondo de a media seja 5 e o desvio padrao 2.5, assim o sistema
    # devera cortar os stems que estao entre 2.5 e 7.5 (Cuidado!!
    # Estes valores nao sao as frequencias dos stems, mas o ranking da
    # frequencia). Os valores do ranking sao sempre numeros inteiros e
    # portanto o intervalo do rank e [3,7].

    # O corte e feito sempre sobre a frequencia dos stems assim e
    # necessario converter estes valores do rank para frequencia

    $maxFreq = $aRank[$min];
    $minFreq = $aRank[$max];

    $msg->openReportFile();
    $stdDev = sprintf("%2.2f",$stdDev);
    $msg->printMsg(" Rank: Standart Deviation",$stdDev);
    $msg->printMsg(" Rank: Mean",$mean);
    $msg->printMsg(" Rank: Multiplicator",$mult);
    $msg->printMsg(" Rank: Rank Range","[$min,$max]");
    $msg->printMsg(" Rank: Frequency Range","[$minFreq,$maxFreq]");
    $msg->closeReportFile();

    $dTable->cutMaxMin($maxFreq,$minFreq);
}

1;
