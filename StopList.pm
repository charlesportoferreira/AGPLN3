package StopList;

use strict;
use warnings;
use IO::File;
use Message;
use StopFiles;

#--------------------------------------------------
# Construtor
# Parametro 0 = Configuracao
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {};

    bless $self, $class;

    $self->{config} = $_[0];
    $self->{dir} = undef;
    $self->{numStopWords} = 0;
    $self->{numStopFiles} = 0; 
    $self->{fileNamesSF} = ();
    $self->{stopList} = ();
    $self->{language} = undef;
    
    $self->setDir($self->{config}->getDirStopList());
    $self->setLanguage($self->{config}->getLanguage());
    $self->addStopFiles($self->{config}->getStopFiles);

    return $self;
}

#--------------------------------------------------
# Define diretorio de StopLists
# Parametro 0 = Diretorio
#-------------------------------------------------- 
sub setDir {
    my $self = shift;
    my $dir = $_[0];

    if (-e $dir) {
        $self->{dir} = $dir;
    } else {
        die print "Directory \"$dir\" doesn't exists! Please define or
        create correctly the StopList directory.\n"
    }
}

#--------------------------------------------------
# Define linguagem principal dos textos
# Parametro 0 = Lingua
#-------------------------------------------------- 
sub setLanguage {
    my $self = shift;

    $self->{language} = $_[0];
}

#--------------------------------------------------
# Pega numero de StopFiles
#-------------------------------------------------- 
sub getNumStopFiles {
    my $self = shift;

    return $self->{numStopFiles};
}

#--------------------------------------------------
# Pega numero de StopWords
#-------------------------------------------------- 
sub getNumStopWords {
    my $self = shift;
    
    return $self->{numStopWords};
}

#--------------------------------------------------
# Adiciona um StopFile a StopList
# Parametro 0 = Lista de StopFiles
#-------------------------------------------------- 
sub addStopFiles {
    my $self = shift;
    my $fileNames = $_[0];
    my $file;
   
    foreach $file (@{$fileNames}) {
        if (-r "$file") {
            push(@{$self->{fileNamesSF}}, "$file");
            $self->{numStopFiles} += 1;
        } else {
            print "StopFile \"$file\" doesn't readable.";
        }
    }
}

#--------------------------------------------------
# Le arquivos de StopFile selecionados e guarda as
# StopWords em uma hash
#-------------------------------------------------- 
sub readStopFiles {
    my $self = shift;
    my ($fileName);
  
    %{$self->{stopList}} = ();
    
    foreach $fileName (@{$self->{fileNamesSF}}) {
        my $fileSF = new StopFiles($fileName);
        
        $fileSF->readFile($self->{stopList});
        $self->{numStopWords} += $fileSF->getNumStopWords();
    }
}

#--------------------------------------------------
# Imprime numero de StopWords, e StopFiles na tela
#-------------------------------------------------- 
sub print {
    my $self = shift;
    my $str;
    my $msg = new Message($self->{config});

    $str = "\n    ### STOP LIST ###\n";
    $str.= "    Total StopWords ".$self->getNumStopWords()."\n";
    $str.= "    Total StopFiles ".$self->getNumStopFiles()."\n\n";

    $msg->quickPrint($str);
}

1;
