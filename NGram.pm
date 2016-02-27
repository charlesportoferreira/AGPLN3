package NGram;

use strict;
use warnings;
use TextFiles;
use ProgressBar;
use IO::File;
        
#--------------------------------------------------
# Construtor
# Parametro 0 = Configuracoes
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
    };

    bless $self, $class;
    
    $self->{config} = $_[0];
    $self->{dir} = $self->{config}->getDirTexts() . '_Maid';

    $self->initTextBase();

    return $self;
}

#--------------------------------------------------
# Guarda endereço dos arquivos a serem usados NGram
#-------------------------------------------------- 
sub initTextBase {
    my $self = shift;
    $self->{textFiles} = new TextFiles($self->{dir});
}

#--------------------------------------------------
# Cria NGram de acordo com as configurações
# desejadas
#-------------------------------------------------- 
sub createGram {
    my $self = shift;
    my
    ($n,$i,$j,$start,$finish,$totalWords,$fileName,$text);
    my (@sentences,$sentence,@words,$ngram,@text);
    my ($hAllGram,$hFilesGram);
    my $bar;

    my $file = new IO::File;
    my $totalFiles = $self->{textFiles}->getNumTexts();
    my $hNGram = $self->{config}->getNGram();
   
    foreach $n (sort keys %{$hNGram}) {
        $bar = new ProgressBar($self->{config},"Criando $n"."Gram",$totalFiles);
        $bar->StartBar();

        %{$hAllGram} = ();
        %{$hFilesGram} = ();

        $self->initTxtFiles($n);
        
        for ($i=0;$i<$totalFiles;$i++) {
            $fileName = $self->{textFiles}->getFileName($i);

            $file->open("<$fileName")
                || die "Can't open $fileName\n";
            @text = <$file>;
            $file->close;

            $text = join(" ",@text);
            @sentences = split(/\|/,$text);

            foreach $sentence (@sentences) {
                $sentence =~ s/^\s+//g;
                $sentence =~ s/\s+$//g;
                
                @words = split(/\s+/,$sentence);
                
                $totalWords = scalar(@words);
                $start = 0;
                $finish = $n - 1;
                
                while ($totalWords > $finish) {
                    $ngram = "";
                    
                    for ($j=$start;$j<=$finish;$j++) {
                        $ngram .= $words[$j]."_";
                    }
                   
                    $ngram =~ s/_$//;
                    chomp($ngram);
                    
                    if (!defined ($hAllGram->{$ngram})) {
                        $hAllGram->{$ngram} = 1;
                    } else {
                        $hAllGram->{$ngram} += 1;
                    }

                    if (!defined ($hFilesGram->{$fileName})) {
                        $hFilesGram->{$fileName}->{$ngram} = 1;
                    } else {
                        $hFilesGram->{$fileName}->{$ngram} += 1;
                    }
                   
                    $start++;
                    $finish++;
                }
            }
            $self->createTxtFile($n,$hFilesGram);
            undef %{$hFilesGram};

            $self->createABCFile($n,$hAllGram);
            undef %{$hAllGram};

            $bar->RefreshBar();
        }
        
        $bar->EndBar();
        $bar = undef;

        $self->sortTMPFiles($n,$totalFiles);
    }
}

#--------------------------------------------------
# Inicia arquivos de informações sobre o NGram
# Parametro 0 = Numero de Gram
#-------------------------------------------------- 
sub initTxtFiles {
    my $self = shift;
    my $n = $_[0];
    my $file = new IO::File;
    my $dir = $self->{config}->getDirNGram();

    if (! -d $dir) {
        mkdir $dir;
    }

    $file->open(">$dir/$n"."Gram.txt")
        || die "Can't open $dir/$n"."Gram.txt\n";
    $file->close;
}

#--------------------------------------------------
# Cria arquivos de informação sobre o NGram
# Parametro 0 = Numero de Gram
# Parametro 1 = Hash de Gram por arquivo
#-------------------------------------------------- 
sub createTxtFile {
    my $self = shift;
    my $n = $_[0];
    my $hFilesGram = $_[1];

    my ($ngram,$fileName);
    my $file = new IO::File;
    my $dir = $self->{config}->getDirNGram();

    #----------------------------------------------
    # Criando arquivo NGram.txt
    #----------------------------------------------
    $file->open(">>$dir/$n"."Gram.txt")
        || die "Can't open $dir/$n"."Gram.txt\n";

    foreach $fileName (sort keys %{$hFilesGram}) {
        print $file "$fileName\n";
        foreach $ngram (sort keys %{$hFilesGram->{$fileName}}) {
            print $file
                "       $ngram:$hFilesGram->{$fileName}->{$ngram}\n";
        }
    }

    $file->close;
}

#--------------------------------------------------
# Cria arquivos temporários para utilização
# posterior
# Parametro 0 = Numero de Gram
# Parametro 1 = Hash de todas Gram
#-------------------------------------------------- 
sub createABCFile {
    my $self = shift;
    my $n = $_[0];
    my $hAllGram = $_[1];

    my ($ngram,$abc);
    my $file = new IO::File;
    my $dir = $self->{config}->getDirNGram();

    if (! -d $dir) {
        mkdir $dir;
    }

    #----------------------------------------------
    # Criando arquivo NGram.tmp
    #----------------------------------------------
    $file->open(">>$dir/$n"."Gram-a.tmp")
        || die "Can't open $dir/$n"."Gram-".$abc.".tmp\n";

    $abc = "a";
    
    foreach $ngram
        (sort keys %{$hAllGram}) {

        if ($ngram !~ /^$abc/) {
            if ($ngram =~ /^[a-z]/) {
                while ($ngram !~ /^$abc/) {
                    $abc++;
                    if ($abc !~ /^[a-z]$/) {
                        $abc = "a";
                    }
                }
                
                $file->close;
                $file->open(">>$dir/$n"."Gram-".$abc.".tmp")
                    || die "Can't open $dir/$n"."Gram-".$abc.".tmp\n";
            } else {
                $abc = "aa";
                $file->close;
                $file->open(">>$dir/$n"."Gram--.tmp")
                    || die "Can't open $dir/$n"."Gram--.tmp\n";
            }
        }
        
        print $file 
            $hAllGram->{$ngram}.":$ngram\n";
    }
    
    $file->close;
}

#--------------------------------------------------
# Organiza arquivos temporarios
# Parametro 0 = Numero de Gram
# Parametro 1 = Numero total de arquivos lidos
#-------------------------------------------------- 
sub sortTMPFiles {
    my $self = shift;
    my $n = $_[0];
    my $totalFiles = $_[1];

    my ($ngram,$abc,$hGram,@file,$line,$count);
    my $file = new IO::File;
    my $newFile = new IO::File;
    my $dir = $self->{config}->getDirNGram();

    %{$hGram} = ();
    $abc = "a";
    $newFile->open(">$dir/$n"."Gram.all")
        || die "Can't open $dir/$n"."Gram.all\n";

    while ($abc !~ /^\-$/) {
        if ($abc !~ /^[a-z]$/) {
            $abc = "-";
        }

        if ($file->open("<$dir/$n"."Gram-".$abc.".tmp")) {
            @file = <$file>;
            $file->close;
            
            foreach $line (@file) {
                ($count, $ngram) = split(/\:/,$line);
                chomp($ngram);
        
                if (!defined ($hGram->{$ngram})) {
                    $hGram->{$ngram}->{count} = $count;
                    $hGram->{$ngram}->{files} = 1;
                } else {
                    $hGram->{$ngram}->{count} += $count;
                    $hGram->{$ngram}->{files} += 1;
                }
            }
        }
       
        if ($abc !~ /^\-$/) {
            $abc++;
        }

        #NGram com frequencia 1 sao gravados no arquivo e
        #tirados da hash para economizar memoria
        foreach $ngram (keys %{$hGram}) {
            if ($hGram->{$ngram}->{count} == 1) {
                print $newFile
                    $hGram->{$ngram}->{count}.":($hGram->{$ngram}->{files}/$totalFiles):$ngram\n";
                delete $hGram->{$ngram};
            }
        }
    }
   
    unlink <$dir/*.tmp>;
   
    foreach $ngram
       (sort {$hGram->{$a}->{count} <=> $hGram->{$b}->{count}} keys %{$hGram}) {
        print $newFile
            $hGram->{$ngram}->{count}.":($hGram->{$ngram}->{files}/$totalFiles):$ngram\n";
    }

    $newFile->close;
    undef %{$hGram};    
}

1;
