package StopFiles;

use strict;
use warnings;
use XML::Parser;
use IO::File;

#--------------------------------------------------
# Contrutor
# Parametro 0 = Arquivo StopFile
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {};

    bless $self, $class;

    $self->{numStopWords} = undef;
    $self->{fileName} = undef;

    $self->setFileName($_[0]);

    return $self;
}

#--------------------------------------------------
# Inicia nome do arquivo
# Parametro 0 = Arquivo
#-------------------------------------------------- 
sub setFileName {
    my $self = shift;
    my $filename = $_[0];

    if (-r $filename) {
        $self->{fileName} = $filename;
    } else {
        die "$filename is not readable:$!\n";
    }
}

#--------------------------------------------------
# Devolve a quantidade de StopWords no StopFile
#-------------------------------------------------- 
sub getNumStopWords {
    my $self = shift;
    
    return $self->{numStopWords};
}

#--------------------------------------------------
# Le StopFile e armazena as StopWords em uma hash
# Parametro 0 = Ponteiro pra hash de StopWords
#-------------------------------------------------- 
sub readFile {
    my $self = shift;
    my $i;
    my $parser = XML::Parser->new(Style => 'Tree');
    my $tree = $parser->parsefile($self->{fileName});
    my $stopList = $_[0];

    @{$tree}[0] eq "stopfile" || die "XML Stopfile File not valid!\n";
    my $stopfile = @{$tree}[1];

    $self->{numStopWords} = 0;
    
    $i = 3;

    while ((defined @{$stopfile}[$i]) && (@{$stopfile}[$i] eq "stopword")) {
        $stopList->{"@{@{$stopfile}[$i+1]}[2]"} = 1;
        $self->{numStopWords} += 1;
        $i += 4;
    }
}

1;
