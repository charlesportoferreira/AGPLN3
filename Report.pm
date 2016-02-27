package Report;

use warnings;
use strict;
use Message;
use DiscoverData;
use DiscoverTable;
use GraphicsTxt;
use Cuts;
use Taxonomy;
use Measure;
use IO::File;
use ProgressBar;

#--------------------------------------------------
# Construtor
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
        config => $_[0],
        DData => undef,
        Cuts => undef,
        Measure => undef,
        Taxonomy => undef,
        hClass => undef, # se disponivel, essa hash contem as classes.
        gramsEnabled => undef,
        DTables => undef
    };

    bless $self, $class;

    $self->{DData}    = new DiscoverData();
    $self->{Cuts}     = new Cuts($self->{config});
    $self->{Measure}  = new Measure($self->{config});
    $self->{Taxonomy} = new Taxonomy($self->{config});
    $self->{hClass}   = ();

    $self->constructTables();

    $self->buildDiscoverFiles();

    return $self;
}

#--------------------------------------------------
# Cria tabelas atributo-valor vazias para cada gram
#-------------------------------------------------- 
sub constructTables {
    my $self = shift;
    my ($ngram,$gram);

    $ngram = $self->{config}->getReportConfig();

    foreach $gram (sort keys %{$ngram}) {
        push(@{$self->{gramsEnabled}},$gram);
    }

    foreach $gram (@{$self->{gramsEnabled}}) {
        $self->{DTables}->{$gram} = new
        DiscoverTable($self->{config},$gram,$self->{DData},$self->{Taxonomy});
    }
}

#--------------------------------------------------
# Leitura dos arquivos de NGram para criação criacao
# da tabela atributo-valor
#-------------------------------------------------- 
sub buildDiscoverFiles {
    my $self = shift;
    my $msg = new Message($self->{config});
    my ($gram,$mult,$graphic,$str);

    foreach $gram (@{$self->{gramsEnabled}}) {
        if ($gram < 10) {
            $msg->quickPrint("\n#------ $gram-Gram -----#\n")
        } else {
            $msg->quickPrint("\n#----- $gram-Gram -----#\n")
        }

        # Carregando os stems dos N-Gram
        $self->{DTables}->{$gram}->loadGramBase();

        # Criando o array de stem no DNames. Esse passo e necessario
        # para o GraphicsTxt e o rankStdDev
        $self->{DTables}->{$gram}->{DNames}->prepareArrayFreq();

        # Cria graficos baseados na frequencia dos gram
        $graphic = new GraphicsTxt($self->{config},$self->{DTables}->{$gram});
        $graphic = undef;
        
        $mult = $self->{config}->getReportConfig()->{$gram}->{std_dev};
        if (defined $mult) {
            $self->{Cuts}->rankStdDev($mult,$self->{DTables}->{$gram});
            $self->{DTables}->{$gram}->{DNames}->prepareArrayFreq();
            $msg->quickPrint(" Number of $gram-Gram after Cuts",
                scalar @{$self->{DTables}->{$gram}->{DNames}->{aNames}});
        }
        $msg->quickPrint("\n");
        
        $self->{DData}->prepareArray();
        $self->{Measure}->load($self->{DTables}->{$gram});
    }
    
    $self->summary();

    $str = $self->matrixDensity()*100;
    $str = sprintf("%2.2f",$str);
    $msg->quickPrint("\n");
    $msg->quickPrint("Matrix Density",$str);

    $msg->quickPrint("\n#--- Discovery Table ---#\n");
    # DiscoverData deve ser criado primeiro para pegar os nomes das classes

    if ($self->{config}->getTranspose() eq "ENABLED") {
        $self->createDiscoverDataT();
        $self->createDiscoverNamesT();
    } else {
        $self->createDiscoverData();
        $self->createDiscoverNames();
    }
}

#--------------------------------------------------
# Imprime sumario final de Stems e Textos que serao
# utilizados na geracao da tabela atributo-valor
# para todos os N-Gram
#-------------------------------------------------- 
sub summary {
    my $self = shift;
    my $gram;
    my $msg  = new Message($self->{config});
    
    $msg->quickPrint("\n======= Summary =======\n");
    foreach $gram (@{$self->{gramsEnabled}}) {
        $msg->quickPrint($self->{DTables}->{$gram}->summary());
    }
}

#--------------------------------------------------
# Cria matriz de densidade
#-------------------------------------------------- 
sub matrixDensity {
    my $self = shift;
    my ($gram,$n,$x,$y);

    $x = 0;
    $n = 0;
    $y = $self->{DData}->getNum();

    foreach $gram (@{$self->{gramsEnabled}}) {
        $n += $self->{DTables}->{$gram}->countValid();
        $x += $self->{DTables}->{$gram}->{DNames}->getNum();
    }
    
    return $n/($x+$y);
}

#--------------------------------------------------
# Cria arquivo discover.data
#-------------------------------------------------- 
sub createDiscoverData {
    my $self      = shift;
    my $dir       = $self->{config}->getDiscoverDir();
    my $msg       = new Message($self->{config});
    my $file      = new IO::File;
    my ($data,$n,$bar);

    $n = @{$self->{DData}->{aData}};

    mkdir $dir;
    $file->open(">$dir/discover.data")
        || die "Error! Can't create $dir/discover.data!\n";

    $bar = new ProgressBar($self->{config},"Discover Data",$n);

    $bar->StartBar();

    foreach $data (@{$self->{DData}->{aData}}) {
        print $file $self->getLine($data->getFileName());
        $bar->RefreshBar();
    }

    $bar->EndBar();
    $file->close;
    
    $msg->quickPrint("Number of Texts",$n);
}

#--------------------------------------------------
# Cria arquivo discover.data transposta
#-------------------------------------------------- 
sub createDiscoverDataT {
    my $self      = shift;
    my $dir       = $self->{config}->getDiscoverDir();
    my $msg       = new Message($self->{config});
    my $file      = new IO::File;
    my ($name,$n,$bar,$gram);

    $n = 0;
    foreach $gram (@{$self->{gramsEnabled}}) {
        $n += @{$self->{DTables}->{$gram}->{DNames}->{aNames}};
    }

    mkdir $dir;
    $file->open(">$dir/discover.data")
        || die "Error! Can't create $dir/discover.data!\n";

    $bar = new ProgressBar($self->{config},"Discover Data",$n);

    $bar->StartBar();

    foreach $gram (@{$self->{gramsEnabled}}) {
        foreach $name (@{$self->{DTables}->{$gram}->{DNames}->{aNames}}) {
            print $file $self->getCol($name->getStem());
            $bar->RefreshBar();
        }
    }

    $bar->EndBar();
    $file->close;
    
    $msg->quickPrint("Number of Stems",$n);
}

#--------------------------------------------------
# Cria arquivo discover.data Trasposto
#-------------------------------------------------- 
sub createDiscoverNamesT {
    my $self      = shift;
    my $dir       = $self->{config}->getDiscoverDir();
    my $msg       = new Message($self->{config});
    my $file      = new IO::File;
    my ($data,$n,$bar);

    $n = @{$self->{DData}->{aData}};

    mkdir $dir;
    $file->open(">$dir/discover.names")
        || die "Error! Can't create $dir/discover.names!\n";

    $bar = new ProgressBar($self->{config},"Discover Names",$n);

    $bar->StartBar();
    
    print $file "stem:string:ignore.\n";

    foreach $data (@{$self->{DData}->{aData}}) {
        print $file "\"".$data->getFileName()."\":real.\n";
        $bar->RefreshBar();
    }
    
    $bar->EndBar();
    $file->close;
    
    $msg->quickPrint("Number of Texts",$n);
}


#--------------------------------------------------
# Cria arquivo discover.data
#-------------------------------------------------- 
sub createDiscoverNames {
    my $self      = shift;
    my $dir       = $self->{config}->getDiscoverDir();
    my $msg       = new Message($self->{config});
    my $file      = new IO::File;
    my ($data,$n,$bar,$class,$nClass,$str,$gram);

    $nClass = scalar keys %{$self->{hClass}};
    $n      = 3 + @{$self->{gramsEnabled}};

    mkdir $dir;
    $file->open(">$dir/discover.names")
        || die "Error! Can't create $dir/discover.names!\n";

    $bar = new ProgressBar($self->{config},"Discover Names",$n);

    $bar->StartBar();
    
    if ($nClass > 1) {
        print $file "att_class.\n";
    }
    $bar->RefreshBar();

    print $file "filename:string:ignore.\n";
    $bar->RefreshBar();

    $n = 0;

    foreach $gram (@{$self->{gramsEnabled}}) {
        print $file $self->{DTables}->{$gram}->printNames();
        $n += $self->{DTables}->{$gram}->{DNames}->getNum();
        $bar->RefreshBar();
    }
    
    if ($nClass > 1) {
        $str = "att_class:nominal(";
        foreach $class (keys %{$self->{hClass}}) {
            $str .= "\"$class\",";
        }
        chop($str);
        $str .= ").\n";
        print $file $str;
    }
    $bar->RefreshBar();

    $bar->EndBar();
    $file->close;
    
    $msg->quickPrint("Number of Stems",$n);
}

#--------------------------------------------------
# Retorna uma coluna contendo o conteudo de um
# determinado stem
# Parametro 0 = Nome do Stem
#-------------------------------------------------- 
sub getCol {
    my $self = shift;
    my $stem = $_[0];
    my $gram;
    my $str  = '';

    foreach $gram (@{$self->{gramsEnabled}}) {
        $str .= $self->{DTables}->{$gram}->getTableCol($stem);
    }
    
    chop($str); # tira a ultima virgula
    return "\"$stem\",$str\n";
}

#--------------------------------------------------
# Retorna uma linha contendo o conteudo de um
# determinado arquivo
# Parametro 0 = Nome do Arquivo
#-------------------------------------------------- 
sub getLine {
    my $self     = shift;
    my $filename = $_[0];
    my $gram;
    my $str      = '';

    foreach $gram (@{$self->{gramsEnabled}}) {
        $str .= $self->{DTables}->{$gram}->getTableLine($filename);
    }
    
    if ($filename =~ /\/(.+)\/.+$/) {
        if (! defined $self->{hClass}->{$1}) {
            $self->{hClass}->{$1} = 1;
        }
        return "\"$filename\",$str$1\n";
    } else {
        chop($str); # tira a ultima virgula
        return "\"$filename\",$str\n";
    }
}

1;
