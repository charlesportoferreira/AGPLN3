package GraphicsTxt;

use warnings;
use strict;
use IO::File;
use Message;

#--------------------------------------------------
# Construtor
# Parametro 0 = Configuracoes
# Parametro 1 = Discover Table
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
        config => $_[0],
        dir => undef,
        dTable => $_[1]
    };

    bless $self,$class;

    $self->{dir} = $self->{config}->getGraphicsDir();

    if (! -d $self->{dir}) {
        mkdir $self->{dir};
    }
    
    $self->create();
    
    return $self;
}

#--------------------------------------------------
# Chama metodos de criação de graficos
#-------------------------------------------------- 
sub create {
    my $self = shift;

    $self->createStdDev();
    $self->createStdDevFF();
    $self->createGnuPlot();
}

#--------------------------------------------------
# Cria dados para plotar grafico
#-------------------------------------------------- 
sub createStdDev {
    my $self = shift;
    my $filename = "$self->{dir}\/".$self->{dTable}->getGram()."\-StdDev.dat";
    my $msg = new Message($self->{config});
    my $file = new IO::File;
    my ($names,@aFreq,$n,$i,$count);

    foreach $names (@{$self->{dTable}->{DNames}->{aNames}}) {
        if (!defined $aFreq[$names->getFreq()]) {
            $aFreq[$names->getFreq()] = 1;
        }
    }

    $n = scalar @aFreq;
    $count = 1;

    $file->open(">$filename")
        || die "Can't create $filename!\n";

    for ($i=$n;$i>0;$i--) {
        if (defined ($aFreq[$i])) {
            print $file "$count	$i\n";
            $count++;
        }
    }

    $file->close;

    $msg->quickPrint(" $filename created!\n");
}

#--------------------------------------------------
# Cria dados para plotar grafico
#-------------------------------------------------- 
sub createStdDevFF {
    my $self = shift;
    my $filename = "$self->{dir}\/".$self->{dTable}->getGram()."\-StdDevFF.dat";
    my $msg = new Message($self->{config});
    my $file = new IO::File;
    my ($names,@aFreq,$n,$i);

    foreach $names (@{$self->{dTable}->{DNames}->{aNames}}) {
        if (defined $aFreq[$names->getFreq()]) {
            $aFreq[$names->getFreq()] += 1;
        } else {
            $aFreq[$names->getFreq()] = 1;
        }
    }

    $n = scalar @aFreq;

    $file->open(">$filename")
        || die "Can't create $filename!\n";

    for ($i=$self->{dTable}->getMin();$i<$n;$i++) {
        #if (!defined $aFreq[$i]) {
        #    $aFreq[$i] = 0;
        #}
        if (defined $aFreq[$i]) {
            print $file "$i	$aFreq[$i]\n";
        }
    }

    $file->close;

    $msg->quickPrint(" $filename created!\n");
}

#--------------------------------------------------
# Cria script para GnuPlot
#-------------------------------------------------- 
sub createGnuPlot {
    my $self = shift;
    my $gram = $self->{dTable}->getGram();
    my $filename = "$self->{dir}\/".$gram."\-GnuPlot.script";
    my $msg = new Message($self->{config});
    my $file = new IO::File;
    
    
    $file->open(">$filename")
        || die "Can't create $filename!\n";

    print $file "set terminal latex\n";
    print $file "set pointsize 1.5\n";
    print $file "set output '".$gram."\-StdDev.tex'\n";
    print $file "plot '".$gram."\-StdDev.dat' with linespoints\n";
    print $file "set output '".$gram."\-StdDevFF.tex'\n";
    print $file "plot '".$gram."\-StdDevFF.dat' with linespoints\n";
        
    $file->close;

    $msg->quickPrint(" $filename created!\n");
}

1;
