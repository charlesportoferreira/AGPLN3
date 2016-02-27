package Taxonomy;

use warnings;
use strict;
use Message;
use IO::File;

#--------------------------------------------------
# Construtor
# Parametro 0 = Configuracoes
#--------------------------------------------------
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
        config => $_[0],
        filename => undef,
        stems => undef
    };

    bless $self, $class;

    $self->{filename} = $self->{config}->getTaxonomyFile();

#    if ($self->{filename} eq "") {
#        die "You must define the Taxonomy File Name\n";
#    }

    $self->{stems} = ();
    
    my $msg = new Message($self->{config});
    
    $msg->openReportFile();
    if (-e $self->{filename}) {
        $msg->printMsg("\n    ### Taxonomy Loaded ###\n");
        $self->loadFile();
    } else {
        $msg->printMsg("\n    ### Taxonomy was NOT Loaded ###\n");
    }
    $msg->closeReportFile();

    return $self;
}

#--------------------------------------------------
# Carrega arquivo de taxonomia na memoria.
#-------------------------------------------------- 
sub loadFile {
    my $self = shift;
    my $file = new IO::File;
    my (@file,@line,$fullLine,$root,$cont);
    my ($totalElem,$i);
    my $msg = new Message($self->{config});

    $file->open("$self->{filename}")
        || die "Can't open $self->{filename}";
    @file = <$file>;
    $file->close;

    $cont = 0;

    foreach $fullLine (@file) {
        chop ($fullLine);
        $fullLine =~ s/ +|\t|\f|\a|\e//g;
        
        # ignorar comentarios e espacos
        if (($fullLine !~ /^\#/) && (length($fullLine) > 0)) {
            $fullLine =~ tr/[A-Z]/[a-z]/;
            
            @line = split(/,|:/,$fullLine);
            
            $totalElem = scalar @line;
            
            $root = $line[0];
            $root =~ tr/[a-z]/[A-Z]/;

            for ($i=1;$i<$totalElem;$i++) {
                $self->{stems}->{$line[$i]} = $root;
            }
            
            $cont++;
        }
    }

    $msg->quickPrint("    Total Taxonomy ".$cont."\n");
}

#--------------------------------------------------
# Checa se existe uma taxonomia para o stem ou nao
# e retorna a taxonomia se existir.
# Parametro 0 = Stem Base
#-------------------------------------------------- 
sub check {
    my $self = shift;
    my $stem = $_[0];

    if (defined $self->{stems}->{$stem}) {
        return $self->{stems}->{$stem};
    } else {
        return $stem;
    }
}

1;
