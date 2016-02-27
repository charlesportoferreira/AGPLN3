package DiscoverTable;

use warnings;
use strict;
use Message;
use ProgressBar;
use DiscoverNames;
use IO::File;

#--------------------------------------------------
# Construtor
# Parametro 0 = Configuracao
# Parametro 1 = Numero de Gram
# Parametro 2 = Discover Data
# Parametro 3 = Taxonomias
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {
        table    => undef,
        config   => $_[0],
        gram     => $_[1],
        DData    => $_[2],
        taxonomy => $_[3],
        DNames   => undef
    };

    bless $self, $class;

    $self->{table}  = ();
    $self->{DNames} = new DiscoverNames();
    
    return $self;
}

#--------------------------------------------------
# Leitura dos arquivos gram.all e gram.txt
#-------------------------------------------------- 
sub loadGramBase {
    my $self = shift;
    my $dir  = $self->{config}->getReportNGramDir();

    $self->loadAll($dir);
    $self->loadTxt($dir);
}

#--------------------------------------------------
# Leitura do arquivo gram.all
# Parametro 0 = Diretorio de info de NGram
#-------------------------------------------------- 
sub loadAll {
    my $self              = shift;
    my $dir               = $_[0];
    my $filename          = "$dir/$self->{gram}"."Gram.all";
    my $msg               = new Message($self->{config});
    my $bar;
    my $reportCfg         = $self->{config}->getReportConfig();
    my $file              = new IO::File;
    my $max               = $reportCfg->{$self->{gram}}->{max};
    my $min               = $reportCfg->{$self->{gram}}->{min};
    my $maxFiles          = $reportCfg->{$self->{gram}}->{maxFiles};
    my $minFiles          = $reportCfg->{$self->{gram}}->{minFiles};
    my $ignoredByMax      = 0;
    my $ignoredByMin      = 0;
    my $ignoredByMaxFiles = 0;
    my $ignoredByMinFiles = 0;
    my (@file,$line,$freq,$countFile,$stem);

    $file->open("<$filename")
        || die "DiscoverTable: Can't open $filename!\nPlease define ".
        "correctly the NGram directory in config.xml.\n";
    @file = <$file>;
    $file->close;

    $bar = new ProgressBar
        ($self->{config},$self->{gram}."Gram.all",scalar @file);
    $bar->StartBar();

    foreach $line (@file) {
        chomp($line);

        if ($line !~ /#/) { #ignorar comentarios
            $line =~ s/\s+//g;

            ($freq, $countFile,$stem) = split(/:/,$line);
            
            $countFile =~ /\((\d+)\/\d+\)/;
            $countFile = $1;

            if ((defined $max) && ($freq > $max)) {
                $ignoredByMax++;
            } elsif ((defined $min) && ($freq < $min)) {
                $ignoredByMin++;
            } elsif ((defined $maxFiles) && ($countFile > $maxFiles)) {
                $ignoredByMaxFiles++;
            } elsif ((defined $minFiles) && ($countFile < $minFiles)) {
                $ignoredByMinFiles++;
            } else {
                $stem = $self->{taxonomy}->check($stem);
                $self->{DNames}->insertStem($stem,$freq);
            }
        }
        $bar->RefreshBar();
    }

    $bar->EndBar();
    $bar = undef;
    
    $msg->openReportFile();
    
    if (defined $max) { 
        $msg->printMsg
            (" Cut with user defined restriction max = $max",$ignoredByMax);
    }
    if (defined $min) { 
        $msg->printMsg
            (" Cut with user defined restriction min = $min",$ignoredByMin);
    }
    if (defined $maxFiles) { 
        $msg->printMsg
            (" Cut with user defined restriction max files = $maxFiles",
             $ignoredByMaxFiles);
    }
    if (defined $minFiles) { 
        $msg->printMsg
            (" Cut with user defined restriction min files = $minFiles",
             $ignoredByMinFiles);
    }
    $msg->printMsg
        (" Number of $self->{gram}-gram loaded from $filename",
         $self->{DNames}->getNum());
    $msg->printMsg("\n");

    $msg->closeReportFile();
}

#--------------------------------------------------
# Leitura do arquivo gram.txt
# Parametro 0 = Diretorio de info de NGram
#-------------------------------------------------- 
sub loadTxt {
    my $self         = shift;
    my $dir          = $_[0];
    my $filename     = "$dir/$self->{gram}"."Gram.txt";
    my $reportCfg    = $self->{config}->getReportConfig();
    my $file         = new IO::File;
    my $bar;
    my (@file,$line,$freq,$stem,$name);

    $file->open("<$filename")
        || die "DiscoverTable: Can't open $filename!\n";
    @file = <$file>;
    $file->close;

    $bar = new ProgressBar
        ($self->{config},$self->{gram}."Gram.txt",scalar @file);
    $bar->StartBar();
    
    foreach $line (@file) {
        chomp($line);
        if ($line =~/^\s+/) {
            $line =~s/\s+//;
            
            ($stem,$freq) = split(/:/,$line);

            $stem = $self->{taxonomy}->check($stem);

            if (defined $self->{DNames}->{hNames}->{$stem}) {
        #print STDERR ">$line<>$name<>$stem<>$freq<\n";
                $self->insertTableNode($name,$stem,$freq);
            }
        } elsif ($line =~/^\S+/) {
            $name = $line;
            $self->{DData}->insert($name);
        }
        $bar->RefreshBar();
    }
    
    $bar->EndBar();
    $bar = undef;
}

#--------------------------------------------------
# Armazena stems e suas frequencias para cada
# arquivo, e incrementa os contadores para os
# stems por arquivo e arquivo por stem
# Parametro 0 = Nome do arquivo
# Parametro 1 = Stem Base
# Parametro 2 = Frequencia do Stem
#-------------------------------------------------- 
sub insertTableNode {
    my $self     = shift;
    my $filename = $_[0];
    my $stem     = $_[1];
    my $freq     = $_[2];

    if (defined $self->{table}->{$filename}->{$stem}) {
        $self->{table}->{$filename}->{$stem} += $freq;
    } else {
        if ($freq > 0) {
            $self->{DNames}->incCount($stem);
            $self->{DData}->incCount($filename);
        }
        $self->{table}->{$filename}->{$stem} = $freq;
    }
}

#--------------------------------------------------
# Armazena stems e suas frequencias para cada
# arquivo, e incrementa os contadores para os
# stems por arquivo e arquivo por stem
# Parametro 0 = Nome do arquivo
# Parametro 1 = Stem Base
# Parametro 2 = Frequencia do Stem
#-------------------------------------------------- 
sub setTableNode {
    my $self     = shift;
    my $filename = $_[0];
    my $stem     = $_[1];
    my $freq     = $_[2];

    if ($freq > 0) {
        $self->{DNames}->incCount($stem);
        $self->{DData}->incCount($filename);
    }
    $self->{table}->{$filename}->{$stem} = $freq;
}

#--------------------------------------------------
# Retorna sumario final de Stems e Textos que serao
# utilizados na geracao da tabela atributo-valor
#-------------------------------------------------- 
sub summary {
    my $self       = shift;
    my $totalStems = $self->{DNames}->getNum();
    my $totalTexts = scalar keys %{$self->{table}};
    my $str;

    $str  = "   N-Gram   : ".$self->getGram()."\n";
    $str .= "Total Stems : ".$totalStems."\n";
    $str .= "Total Texts : ".$totalTexts."\n";
    $str .= "-----------------------\n";
    
    return $str;
    
}

#--------------------------------------------------
# Elimina stems que estiverem fora dos limites de
# maximo e minimo
# Parametro 0 = Maximo
# Parametro 1 = Minimo
#-------------------------------------------------- 
sub cutMaxMin {
    my $self = shift;
    my $max  = $_[0];
    my $min  = $_[1];
    my $msg  = new Message($self->{config});
    my ($cutMax,$cutMin,$names);

    $cutMax = 0;
    $cutMin = 0;

    foreach $names (@{$self->{DNames}->{aNames}}) {
        if ($names->getFreq() < $min) {
            delete $self->{DNames}->{hNames}->{$names->getStem()};
            $cutMin++;
        } elsif ($names->getFreq() > $max) {
            delete $self->{DNames}->{hNames}->{$names->getStem()};
            $cutMax++;
        }
    }

    $msg->openReportFile();
    
    $msg->printMsg(" Stems cut with std_dev min = $min",$cutMin);
    $msg->printMsg(" Stems cut with std_dev max = $max",$cutMax);

    $self->setMax($max);
    $self->setMin($min);

    $msg->closeReportFile();
}

#--------------------------------------------------
# Retorna a coluna contendo todos os valores dos
# arquivos para um determinado arquivo
# Parametro 0 = Nome do Stem
#-------------------------------------------------- 
sub getTableCol {
    my $self = shift;
    my $stem = $_[0];
    my $str  = "";
    my ($data);
   
    foreach $data (@{$self->{DData}->{aData}}) {
        $str .=
            sprintf("%.2f",$self->getFreq($data->getFileName(),$stem)).',';
    }

    return $str;
}


#--------------------------------------------------
# Retorna a linha contendo todos os valores dos
# atributos para um determinado arquivo
# Parametro 0 = Nome do arquivo
#-------------------------------------------------- 
sub getTableLine {
    my $self     = shift;
    my $filename = $_[0];
    my $str      = "";
    my ($names);
   
    if ($self->{DData}->getType() eq "integer") {
        foreach $names (@{$self->{DNames}->{aNames}}) {
            $str .= $self->getFreq($filename,$names->getStem()).',';
        }
    } elsif ($self->{DData}->getType() eq "real") {
        foreach $names (@{$self->{DNames}->{aNames}}) {
            $str .=
                sprintf("%.2f",$self->getFreq($filename,$names->getStem())).',';
        }
    }

    return $str;
}

#--------------------------------------------------
# Retorna todos os nomes de arquivos armazenados
# nessa tabela.
#-------------------------------------------------- 
sub printFiles {
    my $self = shift;
    my $data;
    my $str  = "";

    foreach $data (@{$self->{DData}->{aData}}) {
        $str .= "\"".$data->getFileName()."\":real.\n";
    }

    return $str;
}


#--------------------------------------------------
# Retorna todos os Stems armazenados nessa tabela.
#-------------------------------------------------- 
sub printNames {
    my $self = shift;
    my $names;
    my $str  = "";

    if ($self->{DData}->getType() eq "integer") {
        foreach $names (@{$self->{DNames}->{aNames}}) {
            $str .= "\"".$names->getStem()."\":integer.\n";
        }
    } elsif ($self->{DData}->getType() eq "real") {
        foreach $names (@{$self->{DNames}->{aNames}}) {
            $str .= "\"".$names->getStem()."\":real.\n";
        }
    }

    return $str;
}

#--------------------------------------------------
# Define limite maximo dos Stems
# Parametro 0 = Maximo
#-------------------------------------------------- 
sub setMax {
    my $self = shift;
    my $reportCfg = $self->{config}->getReportConfig();

    $reportCfg->{$self->{gram}}->{max} = $_[0];
}

#--------------------------------------------------
# Define limite minimo dos Stems
# Parametro 0 = Minimo
#-------------------------------------------------- 
sub setMin {
    my $self = shift;
    my $reportCfg = $self->{config}->getReportConfig();

    $reportCfg->{$self->{gram}}->{min} = $_[0];
}

#--------------------------------------------------
# Pega o limite maximo de Stems
#-------------------------------------------------- 
sub getMax {
    my $self = shift;
    my $reportCfg = $self->{config}->getReportConfig();

    return $reportCfg->{$self->{gram}}->{max};
}

#--------------------------------------------------
# Pega o limite minimo de Stems
#-------------------------------------------------- 
sub getMin {
    my $self = shift;
    my $reportCfg = $self->{config}->getReportConfig();

    if (defined $reportCfg->{$self->{gram}}->{min}) {
        return $reportCfg->{$self->{gram}}->{min};
    } else {
        return 1;
    }
}

#--------------------------------------------------
# Pega valor da frequencia de um Stem em um
# determinado arquivo
# Parametro 0 = Nome do Arquivo
# Parametro 1 = Stem
#-------------------------------------------------- 
sub getFreq {
    my $self     = shift;
    my $filename = $_[0];
    my $stem     = $_[1];

    if (defined $self->{table}->{$filename}->{$stem}) {
        return $self->{table}->{$filename}->{$stem};
    } else {
        return 0;
    }
}

#--------------------------------------------------
# Pega o N de Gram da tabela
#-------------------------------------------------- 
sub getGram {
    my $self = shift;

    return $self->{gram};
}

#--------------------------------------------------
# Zera contadores de Names e Datas
#-------------------------------------------------- 
sub clearCount {
    my $self = shift;
    
    $self->{DNames}->clearCount();
    $self->{DData}->clearCount();
}

#--------------------------------------------------
# Contar quantos Names existem na Discover Table
#-------------------------------------------------- 
sub countValid {
    my $self = shift;
    my ($n, $names);

    $n = 0;
    foreach $names (@{$self->{DNames}->{aNames}}) {
        $n += $names->getCount();
    }

    return $n;
}

1;
