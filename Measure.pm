package Measure;

use warnings;
use strict;
use Message;
use ProgressBar;

#--------------------------------------------------
# Construtor
# Parametro 0 = Configuracoes
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
        config => $_[0]
    };

    bless $self, $class;

    return $self;
}

#--------------------------------------------------
# Carrega medidas
# Parametro 0 = Discover Table
#-------------------------------------------------- 
sub load {
    my $self      = shift;
    my $dTable    = $_[0];
    my $reportCfg = $self->{config}->getReportConfig();
    my $gram      = $dTable->getGram();
    my $msg       = new Message($self->{config});

    my $nFiles    = $dTable->{DData}->getNum();
    
    my $measureC  = "Measure".ucfirst(lc($reportCfg->{$gram}->{measure}));
    eval "require $measureC" or die $@;
    my $measure   = $measureC->new($nFiles);
    
    my $smooth    = $reportCfg->{$gram}->{smooth};

    my $names;

    $msg->openReportFile();

    $msg->printMsg("Loading ".$measure->getName()."\n");

    foreach $names (@{$dTable->{DNames}->{aNames}}) {
        $measure->getValue($names);
    }
    
    if (($measure->hasSmooth()) && ($smooth eq 'enabled')) {
        $msg->printMsg("Loading SMOOTH\n");
        foreach $names (@{$dTable->{DNames}->{aNames}}) {
            if ($names->getAux() == 0) {
                $measure->getSmooth($names);
            }
        }
    }

    $dTable->clearCount();
    
    if (! $measure->isFixed()) {
        $self->tfXaux($dTable);
    } else {
        $self->tfTOaux($dTable);
    }

    if ($measure->isInteger()) {
        $dTable->{DData}->setType(1);
    } else {
        $dTable->{DData}->setType(2);
    }
    
    if (defined $reportCfg->{$gram}->{normalize}) {
        $self->loadNormalize($dTable,$gram);
        $dTable->{DData}->setType(2);
    }
    $msg->closeReportFile();
}

#--------------------------------------------------
# Carrega e roda o metodo de normalização escolhido
# Parametro 0 = Discover Table
#-------------------------------------------------- 
sub loadNormalize {
    my $self      = shift;
    my $dTable    = $_[0];
    my $reportCfg = $self->{config}->getReportConfig();
    my $gram      = $dTable->getGram();
    my $msg       = new Message($self->{config});
    
    my $normalizeC    = "Normalize".ucfirst(lc($reportCfg->{$gram}->{normalize}));
    eval "require $normalizeC" or die $@;
    my $normalize     = $normalizeC->new($self->{config},$dTable); 
    
    $msg->quickPrint("Loading ".$normalize->getName()."\n");
    $normalize->run();
}

#--------------------------------------------------
# Multiplica a frequencia pelo auxiliar para dar
# o novo valor da medida.
# Parametro 0 = Discover Table
# Parametro 1 = Se a medida e ou nao inteira
#-------------------------------------------------- 
sub tfXaux {
    my $self      = shift;
    my $dTable    = $_[0];
    my $isInteger = $_[1];
    my ($names,$stem,$data,$filename,$aux);
    my $n         = scalar @{$dTable->{DNames}->{aNames}};
    my $bar       = new ProgressBar($self->{config},
                                    "Writing Measure",
                                    $n);
    $bar->StartBar();
    foreach $names (@{$dTable->{DNames}->{aNames}}) {
        $stem = $names->getStem();
        foreach $data (@{$dTable->{DData}->{aData}}) {
            $filename = $data->getFileName();
            if (defined $dTable->{table}->{$filename}->{$stem}) {
                $aux = $names->getAux();
                if ($aux != 1) {
                    $dTable->setTableNode
                        ($filename,
                        $stem,
                        ($dTable->getFreq($filename,$stem)*$names->getAux()));
                }
            }
        }
        $bar->RefreshBar();
    }
    $bar->EndBar();
    $bar = undef;
}

#--------------------------------------------------
# Grava a medida fixa na discover table.
# Parametro 0 = Discover Table
# Parametro 1 = Se a medida e ou nao inteira
#-------------------------------------------------- 
sub tfTOaux {
    my $self   = shift;
    my $dTable = $_[0];
    my $isInteger = $_[1];
    my ($names,$stem,$data,$filename);
    my $n      = scalar @{$dTable->{DNames}->{aNames}};
    my $bar    = new ProgressBar($self->{config},
                                 "Writing Measure",
                                 $n);
    $bar->StartBar();
    foreach $names (@{$dTable->{DNames}->{aNames}}) {
        $stem = $names->getStem();
        foreach $data (@{$dTable->{DData}->{aData}}) {
            $filename = $data->getFileName();
            if (defined $dTable->{table}->{$filename}->{$stem}) {
                $dTable->setTableNode
                    ($filename,
                    $stem,
                    $names->getFreq());
            }
        }
        $bar->RefreshBar();
    }

    $bar->EndBar();
    $bar = undef;
}

1;
