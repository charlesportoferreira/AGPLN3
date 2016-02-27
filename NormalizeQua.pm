package NormalizeQua;

use strict;
use warnings;
use ProgressBar;
use Normalize;

use vars qw(@ISA);
@ISA = qw(Normalize);

#--------------------------------------------------
# Construtor
#--------------------------------------------------
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = $class->SUPER::new(@_);
    
    bless $self, $class;

    $self->{normalizeName} = "Quadratic";

    return $self;
}

#--------------------------------------------------
# Normaliza os atributos da Discover Table p/ linha
#--------------------------------------------------
sub runLin {
    my $self   = shift;
    my ($names,$stem,$soma,$data,$filename);
    my $n   = scalar @{$self->{dTable}->{DNames}->{aNames}};
    my $bar = new ProgressBar($self->{config},
                              $self->{normalizeName},
                              $n);
    $bar->StartBar();

    foreach $data (@{$self->{dTable}->{DData}->{aData}}) {
        $filename = $data->getFileName();
        $soma = 0;

        foreach $names (@{$self->{dTable}->{DNames}->{aNames}}) {
            $stem = $names->getStem();
            if (defined $self->{dTable}->{table}->{$filename}->{$stem}) {
                $soma +=
                    $self->{dTable}->{table}->{$filename}->{$stem} *
                    $self->{dTable}->{table}->{$filename}->{$stem};
            }
        }

        $soma = sqrt($soma);

        if ($soma) {
            foreach $names (@{$self->{dTable}->{DNames}->{aNames}}) {
                $stem = $names->getStem();
                if (defined $self->{dTable}->{table}->{$filename}->{$stem}) {
                    $self->{dTable}->setTableNode
                        ($filename,
                         $stem,
                        ($self->{dTable}->{table}->{$filename}->{$stem}/$soma));
                }
            }
        } else {
            foreach $names (@{$self->{dTable}->{DNames}->{aNames}}) {
                $stem = $names->getStem();
                if (defined $self->{dTable}->{table}->{$filename}->{$stem}) {
                    undef $self->{dTable}->{table}->{$filename}->{$stem};
                }
            }
            
        }
        $bar->RefreshBar();
    }
    
    $bar->EndBar();
    $bar = undef;
}

#--------------------------------------------------
# Normaliza os atributos da Discover Table p/ coluna
#--------------------------------------------------
sub runCol {
    my $self   = shift;
    my ($names,$stem,$soma,$data,$filename);
    my $n   = scalar @{$self->{dTable}->{DNames}->{aNames}};
    my $bar = new ProgressBar($self->{config},
                              $self->{normalizeName},
                              $n);
    $bar->StartBar();

    foreach $names (@{$self->{dTable}->{DNames}->{aNames}}) {
        $stem = $names->getStem();
        $soma = 0;

        foreach $data (@{$self->{dTable}->{DData}->{aData}}) {
            $filename = $data->getFileName();
            if (defined $self->{dTable}->{table}->{$filename}->{$stem}) {
                $soma +=
                    $self->{dTable}->{table}->{$filename}->{$stem} *
                    $self->{dTable}->{table}->{$filename}->{$stem};
            }
        }

        $soma = sqrt($soma);

        if ($soma) {
            foreach $data (@{$self->{dTable}->{DData}->{aData}}) {
                $filename = $data->getFileName();
                if (defined $self->{dTable}->{table}->{$filename}->{$stem}) {
                    $self->{dTable}->setTableNode
                        ($filename,
                         $stem,
                        ($self->{dTable}->{table}->{$filename}->{$stem}/$soma));
                }
            }
        } else {
            foreach $data (@{$self->{dTable}->{DData}->{aData}}) {
                $filename = $data->getFileName();
                if (defined $self->{dTable}->{table}->{$filename}->{$stem}) {
                    undef $self->{dTable}->{table}->{$filename}->{$stem};
                }
            }
            
        }
        
        $bar->RefreshBar();
    }
    
    $bar->EndBar();
    $bar = undef;
}
    
1;
