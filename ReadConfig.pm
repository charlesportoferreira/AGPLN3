package ReadConfig;

use strict;
use warnings;
use Message;
use XML::Parser;

#--------------------------------------------------
# Construtor
#--------------------------------------------------
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
        language       => undef,
        pretextOptions => undef,
        silence        => undef,
        logFile        => undef,
        dirTexts       => undef,
        maidOptions    => undef,
        dirStopList    => undef,
        stopFiles      => undef,
        dirStem        => undef,
        dirNGram       => undef,
        hNGram         => undef,
        taxonomyFile   => undef,
        graphics       => undef,
        discover       => undef,
        reportNGramDir => undef,
        transposeDT    => undef,
        hReport        => undef
    };

    bless $self, $class;

    $self->readConfig();

    return $self;
}

#--------------------------------------------------
# Pega lingua principal dos textos
#--------------------------------------------------
sub getLanguage {
    my $self = shift;

    return $self->{language};
}

#--------------------------------------------------
# Pega lingua principal dos textos
#--------------------------------------------------
sub getPretextOptions {
    my $self = shift;

    return $self->{pretextOptions};
}

#--------------------------------------------------
# Pega atributo de silencio
#--------------------------------------------------
sub getSilence {
    my $self = shift;

    return $self->{silence};
}

#--------------------------------------------------
# Pega arquivo de log
#--------------------------------------------------
sub getLogFile {
    my $self = shift;

    return $self->{logFile};
}

#--------------------------------------------------
# Pega diretorio onde os textos estao
#--------------------------------------------------
sub getDirTexts {
    my $self = shift;

    return $self->{dirTexts};
}

#--------------------------------------------------
# Pega opcoes de limpeza do texto
#--------------------------------------------------
sub getMaidOptions {
    my $self = shift;

    return $self->{maidOptions};
}

#--------------------------------------------------
# Pega diretorio da StopList
#--------------------------------------------------
sub getDirStopList {
    my $self = shift;

    return $self->{dirStopList};
}

#--------------------------------------------------
# Pega os arquivos StopFile que serao utilizados
#--------------------------------------------------
sub getStopFiles {
    my $self = shift;

    return $self->{stopFiles};
}

#--------------------------------------------------
# Pega o diretorio onde ficará as informações
# de Stem
#--------------------------------------------------
sub getDirStem {
    my $self = shift;

    return $self->{dirStem};
}

#--------------------------------------------------
# Pega diretorio onde ficara informacoes de NGram
#--------------------------------------------------
sub getDirNGram {
    my $self = shift;

    return $self->{dirNGram};
}

#--------------------------------------------------
# Pega configurações do NGram
#--------------------------------------------------
sub getNGram {
    my $self = shift;

    return $self->{hNGram};
}

#--------------------------------------------------
# Pega configurações de Taxonomia
#--------------------------------------------------
sub getTaxonomyFile {
    my $self = shift;

    return $self->{taxonomyFile};
}

#--------------------------------------------------
# Pega diretorio dos Graficos
#--------------------------------------------------
sub getGraphicsDir {
    my $self = shift;

    return $self->{graphics};
}

#--------------------------------------------------
# Pega diretorio da DiscoverTable
#--------------------------------------------------
sub getDiscoverDir {
    my $self = shift;

    return $self->{discover};
}

#--------------------------------------------------
# Pega diretorio do Ngram a partir do Report
#--------------------------------------------------
sub getReportNGramDir {
    my $self = shift;

    return $self->{reportNGramDir};
}

#--------------------------------------------------
# Verifica se a Discover Table Transposta esta
# ativada
#--------------------------------------------------
sub getTranspose {
    my $self = shift;

    return $self->{transposeDT};
}

#--------------------------------------------------
# Pega configurações de Report
#--------------------------------------------------
sub getReportConfig {
    my $self = shift;

    return $self->{hReport};
}

#--------------------------------------------------
# Leitura de arquivo de configuracao
#--------------------------------------------------
sub readConfig {
    my $self = shift;
    my $i;
    my $pretext;
    my $parser = XML::Parser->new(Style => 'Tree');
    my $tree = $parser->parsefile('config.xml');
    
    @{$tree}[0] eq "pretext" || die "XML Config File not valid!\n";
    $pretext = @{$tree}[1];
    
    #----------------------------------------------
    # Lendo Configuracoes iniciais
    #----------------------------------------------
    if (defined @{$pretext}[0]->{lang}) {
        $self->{language} = @{$pretext}[0]->{lang};
    } else {
        $self->{language} = "pt";
    }

    if (defined @{$pretext}[0]->{dir}) {
        $self->{dirTexts} = @{$pretext}[0]->{dir};
    } else {
        die "XML Config File: Directory missed!\n";
    }
    
    if (defined @{$pretext}[0]->{log}) {
        $self->{logFile} = @{$pretext}[0]->{log};
    } else {
        $self->{logFile} = "pretext.log";
    }

    if (defined @{$pretext}[0]->{silence}) {
        if (@{$pretext}[0]->{silence} eq "on") {
            $self->{silence} = 1;
        } elsif (@{$pretext}[0]->{silence} eq "off") {
            $self->{silence} = 0;
        } else {
            die "XML Config File: Silence option invalid!\n";
        }
    } else {
        $self->{silence} = 0;
    }

    #----------------------------------------------
    # Lendo modulos ativos
    #----------------------------------------------
    $i=3;
    $self->{pretextOptions} = 0;
    
    while (defined @{$pretext}[$i]) {
        if (@{$pretext}[$i] eq "maid") {
            if (!($self->{pretextOptions} & 0b0000001)) {
                $self->{pretextOptions} += 1;
                $self->readMaidConfig(@{$pretext}[$i+1]);
            } else {
                die "XML Config File: Double Maid!\n";
            }
        } elsif (@{$pretext}[$i] eq "ngram") {
            if (!($self->{pretextOptions} & 0b0000010)) {
                $self->{pretextOptions} += 2;
                $self->readNGramConfig(@{$pretext}[$i+1]);
            } else {
                die "XML Config File: Double NGram!\n";
            }
        } elsif (@{$pretext}[$i] eq "report") {
            if (!($self->{pretextOptions} & 0b0000100)) {
                $self->{pretextOptions} += 4;
                $self->readReportConfig(@{$pretext}[$i+1]);
            } else {
                die "XML Config File: Double Report!\n";
            }
        } else {
            die "XML Config File: Invalid Option @{$pretext}[$i]\n";
        }

        $i += 4;
    }
}

#--------------------------------------------------
# Leitura das configuracoes do modulo Maid.pm
# Parametro 0 = Estrutura de configuracao
#-------------------------------------------------- 
sub readMaidConfig {
    my $self = shift;
    my $maid = $_[0];
    my $stemming;
    my $i;
    
    $i=3;
    $self->{maidOptions} = 0;
    
    while (defined @{$maid}[$i]) {
        if (@{$maid}[$i] eq "html") {
            if (!($self->{maidOptions} & 0b0000001)) {
                $self->{maidOptions} += 1;
            } else {
                die "XML Config File: Maid - Double HTML!\n";
            }
        } elsif (@{$maid}[$i] eq "number") {
            if (!($self->{maidOptions} & 0b0000010)) {
                $self->{maidOptions} += 2;
            } else {
                die "XML Config File: Maid - Double Number!\n";
            }
        } elsif (@{$maid}[$i] eq "stoplist") {
            if (!($self->{maidOptions} & 0b0000100)) {
                $self->{maidOptions} += 4;
                $self->readStopListConfig(@{$maid}[$i+1]);
            } else {
                die "XML Config File: Maid - Double StopList!\n";
            }
        } elsif (@{$maid}[$i] eq "simbols") {
            if (!($self->{maidOptions} & 0b0001000)) {
                $self->{maidOptions} += 8;
            } else {
                die "XML Config File: Maid - Double Simbols!\n";
            }

        } elsif (@{$maid}[$i] eq "stemming") {
            if (!($self->{maidOptions} & 0b1000000)) {
                $self->{maidOptions} += 64;
                $stemming = @{$maid}[$i+1];
                if (defined @{$stemming}[0]->{dir}) {
                    $self->{dirStem} = @{$stemming}[0]->{dir};
                } else {
                    $self->{dirStem} = "steminfo";
                }
            } else {
                die "XML Config File: Maid - Double Stemming!\n";
            }
        } else {
            die "XML Config File: Maid - Invalid Option @{$maid}[$i]!\n";
        }

        $i += 4;
    }
}

#--------------------------------------------------
# Leitura das configuracoes de StopList
# Parametro 0 = Estrutura de configuracao
#-------------------------------------------------- 
sub readStopListConfig {
    my $self = shift;
    my $stoplist = $_[0];
    my $i;
    
    if (defined @{$stoplist}[0]->{dir}) {
        $self->{dirStopList} = @{$stoplist}[0]->{dir};
    } else {
        $self->{dirStopList} = "stoplist";
    }
   
    #----------------------------------------------
    # Pegando stopfiles
    #----------------------------------------------
    $i=3;

    while ((defined @{$stoplist}[$i]) && (@{$stoplist}[$i] eq "stopfile")) {
        push(@{$self->{stopFiles}},
            "$self->{dirStopList}\/@{@{$stoplist}[$i+1]}[2]");
        $i += 4;
    }

    if ($i==3) {
        die "XML Config File: Maid - StopFiles missed!\n";
    }
}

#--------------------------------------------------
# Leitura das configuracoes de NGrama
# Parametro 0 = Estrutura de configuracao
#-------------------------------------------------- 
sub readNGramConfig {
    my $self = shift;
    my $ngram = $_[0];
    my ($gram, $n);
    my $i;
    
    if (defined @{$ngram}[0]->{dir}) {
        $self->{dirNGram} = @{$ngram}[0]->{dir};
    } else {
        $self->{dirNGram} = "ngraminfo";
    }
   
    #----------------------------------------------
    # Pegando numero de grama
    #----------------------------------------------
    $i=3;
    %{$self->{hNGram}} = ();

    while ((defined @{$ngram}[$i]) && (@{$ngram}[$i] eq "gram")) {
        $gram = @{@{$ngram}[$i+1]}[0];
        $n = $gram->{n};
        $self->{hNGram}->{$n}->{n} = $n;
        
        $i += 4;
    }

    if ($i==3) {
        die "XML Config File: NGram - Gram missed!\n";
    }
}

#--------------------------------------------------
# Leitura das configuracoes de Report
# Parametro 0 = Estrutura de configuracao
#-------------------------------------------------- 
sub readReportConfig {
    my $self = shift;
    my $report = $_[0];
    my ($gram, $n);
    my $i;

    if (defined @{$report}[0]->{taxonomy}) {
        $self->{taxonomyFile} = @{$report}[0]->{taxonomy};
    } else {
        $self->{taxonomyFile} = "";
    }
    
    if (defined @{$report}[0]->{graphics}) {
        $self->{graphics} = @{$report}[0]->{graphics};
    } else {
        $self->{graphics} = "graphics";
    }
    
    if (defined @{$report}[0]->{discover}) {
        $self->{discover} = @{$report}[0]->{discover};
    } else {
        $self->{discover} = "discover";
    }
    
    if (defined @{$report}[0]->{ngramdir}) {
        $self->{reportNGramDir} = @{$report}[0]->{ngramdir};
    } else {
        if (defined $self->{dirNGram}) {
            $self->{reportNGramDir} = $self->{dirNGram};
        } else {
            $self->{reportNGramDir} = "ngraminfo";
        }
    }

    $self->{transposeDT} = "DISABLED";
    if (defined @{$report}[0]->{transpose}) {
        if (uc(@{$report}[0]->{transpose}) eq "ENABLED") {
            $self->{transposeDT} = "ENABLED";
        }
    }
    
    #----------------------------------------------
    # Pegando configuracoes de cada grama
    #----------------------------------------------
    $i=3;
    %{$self->{hReport}} = ();

    while ((defined @{$report}[$i]) && (@{$report}[$i] eq "gram")) {
        $gram = @{@{$report}[$i+1]}[0];
        $n = $gram->{n};
        $self->{hReport}->{$n}->{n} = $n;

        if (defined $gram->{max}) {
            $self->{hReport}->{$n}->{max} = $gram->{max};
        }
        
        if (defined $gram->{min}) {
            $self->{hReport}->{$n}->{min} = $gram->{min};
        }
        
        if (defined $gram->{maxfiles}) {
            $self->{hReport}->{$n}->{maxFiles} = $gram->{maxfiles};
        }
        
        if (defined $gram->{minfiles}) {
            $self->{hReport}->{$n}->{minFiles} = $gram->{minfiles};
        }
        
        if (defined $gram->{std_dev}) {
            $self->{hReport}->{$n}->{std_dev} = $gram->{std_dev};
        }

        if (defined $gram->{measure}) {
            $self->{hReport}->{$n}->{measure} = $gram->{measure};
        } else {
            $self->{hReport}->{$n}->{measure} = "tf";
        }

        if (defined $gram->{smooth}) {
            $self->{hReport}->{$n}->{smooth} = uc($gram->{smooth});
            if ((uc($gram->{smooth}) eq "DISABLED") ||
               (uc($gram->{smooth}) eq "ENABLED")) {
                $self->{hReport}->{$n}->{smooth} = uc($gram->{smooth});
            } else {
                die "XML Config File: Report - Invalid Smooth!\n";
            }
        } else {
            $self->{hReport}->{$n}->{smooth} = "DISABLED";
        }

        if (defined $gram->{normalize}) {
            $self->{hReport}->{$n}->{normalize} = $gram->{normalize};
            if (defined $gram->{normalizetype}) {
                if ((lc($gram->{normalizetype}) eq "c") ||
                   (lc($gram->{normalizetype}) eq "l")) {
                    $self->{hReport}->{$n}->{normalizeType} =
                        lc($gram->{normalizetype});
                } else {
                    die "XML Config File: Report - Invalid Normalize Type!\n";
                }
            } else {
                $self->{hReport}->{$n}->{normalizeType} = "c";
            }
        }
        
        $i += 4;
    }

    if ($i==3) {
        die "XML Config File: Report - Gram missed!\n";
    }
}

#--------------------------------------------------
# Imprime configuracoes
#-------------------------------------------------- 
sub printAll {
    my $self = shift;

    $self->printPretext();
    $self->printMaid();
    $self->printNGram();
    $self->printReport();
}

#--------------------------------------------------
# Imprime configuracoes gerais do pretext
#--------------------------------------------------
sub printPretext {
    my $self = shift;
    my $str;
    my $msg = new Message($self);

    $msg->openReportFile();
   
    $msg->printMsg("#-----------------------------#\n");
    $msg->printMsg("#           PreTexT           #\n");
    $msg->printMsg("#                             #\n");
    $msg->printMsg("#    Implemented by LABIC     #\n");
    $msg->printMsg("#-----------------------------#\n");
    $msg->printMsg("\n");
    
    $msg->printMsg("#======== PARAMETERS =========#\n");
    $msg->printMsg(" language     = $self->{language}\n");
    $msg->printMsg(" directory    = $self->{dirTexts}\n");
    if ($self->{logFile} ne "") {
        $msg->printMsg(" log file     = $self->{logFile}\n");
    } else {
        $msg->printMsg(" log file     = pretext.log\n");  
    }
    
    $msg->closeReportFile();
}

#--------------------------------------------------
# Imprime configuracoes do modulo Maid.pm
#--------------------------------------------------
sub printMaid {
    my $self = shift;
    my ($str, $file);
    my $msg = new Message($self);

    $msg->openReportFile();
   
    $msg->printMsg("\n#-----------------------------#\n");
    $msg->printMsg("#           Maid.pm           #\n");
    $msg->printMsg("#-----------------------------#\n");
    $msg->printMsg("\n");
    
    $msg->printMsg("#======== PARAMETERS =========#\n");
    if ($self->{maidOptions} & 0b0000001) {
        $msg->printMsg(" html clear   = ENABLED\n");
    }
    
    if ($self->{maidOptions} & 0b0000010) {
        $msg->printMsg(" number clear = ENABLED\n");
    }
    
    if ($self->{maidOptions} & 0b0001000) {
        $msg->printMsg(" simbol clear = ENABLED\n");
    }

    if ($self->{maidOptions} & 0b0000100) {
        $msg->printMsg(" stoplist     = ENABLED\n");
        
        $msg->printMsg("  > directory = $self->{dirStopList}\n");
        foreach $file (@{$self->{stopFiles}}) {
            $msg->printMsg("  > stopfile  = $file\n")
        }
    }
    
    if ($self->{maidOptions} & 0b1000000) {
        $msg->printMsg(" stemming     = ENABLED\n");
        
        $msg->printMsg("  > directory = $self->{dirStem}\n");
    }
    
    $msg->closeReportFile();
}

#--------------------------------------------------
# Imprime configuracoes
#--------------------------------------------------
sub printNGram {
    my $self = shift;
    my $gram;
    my $msg = new Message($self);

    $msg->openReportFile();
   
    $msg->printMsg("\n#-----------------------------#\n");
    $msg->printMsg("#          NGram.pm           #\n");
    $msg->printMsg("#-----------------------------#\n");
    $msg->printMsg("\n");
    
    $msg->printMsg("#======== PARAMETERS =========#\n");

    $msg->printMsg(" directory    = $self->{dirNGram}\n");

    foreach $gram (sort keys %{$self->{hNGram}}) {
        if ($gram < 10) {
            $msg->printMsg("  $gram-Gram      = ENABLED\n")
        } else {
            $msg->printMsg(" $gram-Gram      = ENABLED\n")
        }
    }
    $msg->printMsg("\n");
    
    $msg->closeReportFile();
}

#--------------------------------------------------
# Imprime configuracoes
#--------------------------------------------------
sub printReport {
    my $self = shift;
    my $gram;
    my $msg = new Message($self);

    $msg->openReportFile();
   
    $msg->printMsg("\n#-----------------------------#\n");
    $msg->printMsg("#          Report.pm          #\n");
    $msg->printMsg("#-----------------------------#\n");
    $msg->printMsg("\n");
    
    $msg->printMsg("#======== PARAMETERS =========#\n");

    $msg->printMsg(" NGram Dir    = $self->{reportNGramDir}\n");
    $msg->printMsg(" Discover Dir = $self->{discover}\n");
    $msg->printMsg(" Graphics Dir = $self->{graphics}\n");

    if ($self->{taxonomyFile} ne "") {
        $msg->printMsg(" Taxonomy     = $self->{taxonomyFile}\n");
    }

    if ($self->{transposeDT} eq "ENABLED") {
        $msg->printMsg(" Transpose    = ENABLED\n");
    }

    foreach $gram (sort keys %{$self->{hReport}}) {
        if ($gram < 10) {
            $msg->printMsg("  $gram-Gram      = ENABLED\n");
        } else {
            $msg->printMsg(" $gram-Gram      = ENABLED\n");
        }

        if (defined $self->{hReport}->{$gram}->{max}) {
            $msg->printMsg
                ("   > Max      = $self->{hReport}->{$gram}->{max}\n");
        }
        
        if (defined $self->{hReport}->{$gram}->{min}) {
            $msg->printMsg
                ("   > Min      = $self->{hReport}->{$gram}->{min}\n");
        }
        
        if (defined $self->{hReport}->{$gram}->{std_dev}) {
            $msg->printMsg
                ("   > Std_Dev  = $self->{hReport}->{$gram}->{std_dev}\n");
        }

        if (defined $self->{hReport}->{$gram}->{maxFiles}) {
            $msg->printMsg
                ("   > Max Files= $self->{hReport}->{$gram}->{maxFiles}\n");
        }
        
        if (defined $self->{hReport}->{$gram}->{minFiles}) {
            $msg->printMsg
                ("   > Min Files= $self->{hReport}->{$gram}->{minFiles}\n");
        }

        $msg->printMsg("   > Measure  = $self->{hReport}->{$gram}->{measure}\n");
                
        if ($self->{hReport}->{$gram}->{smooth} eq "ENABLED") {
            $msg->printMsg("   > Smooth   = ENABLED\n");
        }
        
        if (defined $self->{hReport}->{$gram}->{normalize}) {
            $msg->printMsg
                ("   > Normalize= $self->{hReport}->{$gram}->{normalize}\n");
            $msg->printMsg
                ("   >> Type    = ".
                    ucfirst($self->{hReport}->{$gram}->{normalizeType})."\n");
        }
    }
    
    $msg->closeReportFile();
}

1;
