package Message;

use strict;
use warnings;

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
# Imprime na tela e no arquivo de log alguma string
# Parametro 0 = Primeira string
# Parametro 1 = Segunda string
#-------------------------------------------------- 
sub printMsg {
    my $self = shift;

    if (defined $_[1]) {
        if ($self->{config}->getSilence() == 0) {
            format STDERR =
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  @<<<<<<<<<<<< 
$_[0]                                                   ,$_[1]   
.    
            write STDERR;
        }

        format REPORTFILE=
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  @<<<<<<<<<<<< 
$_[0]                                             ,$_[1]   
.    
        write REPORTFILE;
    } else {
        if ($self->{config}->getSilence() == 0) {
            print STDERR $_[0];
        }
        print REPORTFILE $_[0];
        
    }
}

#--------------------------------------------------
# Imprime na tela mensagem rapida, utilizada para
# quando nao e necessario varias linhas de mensagem
# Parametro 0 = Primeira string
# Parametro 1 = Segunda string
#-------------------------------------------------- 
sub quickPrint {
    my $self = shift;
    
    $self->openReportFile();
    if (defined $_[1]) {
        $self->printMsg($_[0],$_[1]);
    } else {
        $self->printMsg($_[0]);
    }
    $self->closeReportFile();
}

#--------------------------------------------------
# Abre arquivo de log
#--------------------------------------------------
sub openReportFile {
    my $self = shift;
    my $file = $self->{config}->getLogFile();

    open (REPORTFILE,">>$file")
        || die "Can't open $file\n";
}

#--------------------------------------------------
# Fecha arquivo de log
#-------------------------------------------------- 
sub closeReportFile {
    close (REPORTFILE);
}

1;
