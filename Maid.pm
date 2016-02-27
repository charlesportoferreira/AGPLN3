package Maid;

use strict;
use warnings;
use TextFiles;
use StopList;
use Simbols;
use Stemmer;
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
        name => 'Maid',
    };

    bless $self, $class;

    $self->{config} = $_[0];
    $self->{dir} = $self->{config}->getDirTexts();

    $self->callMaid();
    return $self;
}

#--------------------------------------------------
# Chama metodos de limpeza
# 1 = 0b0000001 = HTML
# 2 = 0b0000010 = Numeros
# 4 = 0b0000100 = StopList
# 8 = 0b0001000 = Simbolos 
# 16= 0b0010000 = ?
# 32= 0b0100000 = ?
# 64= 0b1000000 = Steming
#-------------------------------------------------- 
sub callMaid {
    my $self = shift;
    my $options = $self->{config}->getMaidOptions();
    my $file = new IO::File;
    my ($i,$totalFiles,$fileName,@text,$text,$stopList,$langStem,$stem);
    my ($hStemFile, $hStemWord, $hStem);
    my $bar;
    my $textFiles = new TextFiles($self->{dir});
    my $simbols;

    if ($options & 0b0001000) {
        $simbols = new Simbols();
    }
    
    $totalFiles = $textFiles->getNumTexts();
    $textFiles->createDir($self->{name});

    if ($options & 0b0000100) {
        $stopList = new StopList($self->{config});
        $stopList->readStopFiles();
        $stopList->print();
    }
    
    if ($options & 0b1000000) {
        %{$hStemFile} = ();
        %{$hStemWord} = ();
        %{$hStem} = ();
        $langStem = "Stem".ucfirst(lc($self->{config}->getLanguage()));
        eval "require $langStem";
        $stem = $langStem->new();
    }
    
    $bar = new ProgressBar($self->{config},"Maid",$totalFiles);
    $bar->StartBar();

    for ($i=0;$i<$totalFiles;$i++) {
        $fileName = $textFiles->getFileName($i);

        $file->open("<$fileName")
            || die "Can't open $fileName\n";
        @text = <$file>;
        $file->close;

        $text = join(" ",@text);

        if ($options & 0b0000001) {
            $text = $self->htmlClear($text);
        }

        $text = $self->basicClear($text,$options,$simbols);

        if ($options & 0b0000100) {
            $text = $self->stopListClear($text, $stopList);
        }

        if ($options & 0b1000000) {
            $text = $self->finalClear($text);
            $text =
            $self->stemClear($text,$fileName,$hStemWord,$hStemFile,$hStem,$stem);
        }

        $text = $self->finalClear($text);

        $fileName =~ s/^$self->{dir}/$self->{dir}\_$self->{name}/;

        $file->open(">$fileName") || die "Can't open $fileName\n";
    
        if (defined $file) {
            print $file $text;
            $file->close;
        }

        $bar->RefreshBar();
    }
   
    if ($options & 0b1000000) {
        $self->stemFiles($totalFiles,$hStemWord,$hStemFile,$hStem);
    }
   
    $bar->EndBar();
    $bar = undef;
}

#--------------------------------------------------
# Faz a limpeza basica no texto especiais, tirando
# maiusculas, acentos, ç, pontos e outros
# caracteres que devem serem limpos.
# Parametro 0 = Texto 
# Parametro 1 = Opcoes de Uso
# Parametro 2 = Lista de Simbolos para limpeza
#-------------------------------------------------- 
sub basicClear {
    my $self = shift;
    my $text = $_[0];
    my $options = $_[1];
    my $simbols = $_[2];
    my ($i);
       
    #Elimina caixa alta, acentos, e ç
    $text =~
    tr/A-ZÁÀÄÂÃáàäâãÇçÉÈËÊéèëêÍÌÎÏíìîïÓÒÕÔÖóòõôöÚÙÛÜúùûü/a-zaaaaaaaaaaCCeeeeeeeeiiiiiiiioooooooouuuuuuuu/;
    
    #Elimina numeros
    if ($options & 0b0000010) {
        $text =~ s/[0-9]//g;
    }
        
    #Elimina quebras de linha
    $text =~ s/[\n\r]+/\./g;
    $text =~ s/[\n]+/\./g;
        
    #Substitui caracteres diferentes por por |
    $text =~ s/[\a\f]+/ | /g;

    #Limpa simbolos necessários para o PreTexT
    $text =~ s/[\:\|]+/\./g;
    $text =~ s/[\_\-]+/ /g;

    #Limpar lista de simbolos
    if ($options & 0b0001000) {
        $text = $self->clearSimbols($text,$simbols);
    }

    return $text;
}

#--------------------------------------------------
# Limpa os caracteres que fazem parte da lista de
# simbolos.
# Parametro 0 = Texto
# Parametro 1 = Lista de Simbolos para limpeza
#-------------------------------------------------- 
sub clearSimbols {
    my $self = shift;
    my $text = $_[0];
    my $simbols = $_[1];
    my ($simbol, $simbolWb, $simbolNb);

    if ($simbols->getClearAll() eq "TRUE") {
        $text =~ s/[\.\,\;\:\"\'\´\`\!\?\/\\\|\%\+\{\}\[\]\(\)\*]+/ | /g;
        $text =~ s/[^a-zC0-9\|\s]/ /g;
    } else {
        $simbolWb = $simbols->getSimbolWithBreak();
        $text =~ s/[$simbolWb]+/ | /g;

        $simbolNb = $simbols->getSimbolWithoutBreak();
        $text =~ s/[$simbolNb]+/ /g;
    }

    return $text;
}

#--------------------------------------------------
# Trata caracteres especiais HTML e retira tags
# HTML, e XML do texto
# Parametro 0 = Texto
#--------------------------------------------------
sub htmlClear {
    my $self = shift;
    my $text = $_[0];

    #Transforma caracteres especiais (faz parser)
    $text =~
    s/\&aacute\;|\&agrave\;|\&acirc\;|\&atilde\;|\&auml\;/a/gi;
    $text =~ s/\&ccedil\;/ç/gi;
    $text =~
    s/\&eacute\;|\&egrave\;|\&ecirc\;|\&euml\;/e/gi;
    $text =~
    s/\&iacute\;|\&igrave\;|\&icirc\;|\&iuml\;/i/gi;
    $text =~
    s/\&oacute\;|\&ograve\;|\&ocirc\;|\&otilde\;|\&ouml\;/o/gi;
    $text =~
    s/\&uacute\;|\&ugrave\;|\&ucirc\;|\&uuml\;/u/gi;

    #Retira tags HTML
    $text =~ s/<[^>]*>//g;

    return $text;
}

#--------------------------------------------------
# Retira StopWords do texto
# Parametro 0 = Texto
# Parametro 1 = StopList
#--------------------------------------------------
sub stopListClear {
    my $self = shift;
    my $text = $_[0];
    my $stopList = $_[1];
    my (@text,$word);
   
    @text = split(/\s+/,$text);
    $text = "";

    foreach $word (@text) {
        if ($word eq "|") {
            $text .= "| "
        } else {
            if (!defined $stopList->{stopList}->{$word}) {
                $text.= "$word "
            }
        }
    }

    return $text;
}

#--------------------------------------------------
# Transforma palavras em suas respectivas Stem
# Parametro 0 = Texto
# Parametro 1 = Nome do Arquivo
# Parametro 2 = Hash de Stem por Palavras
# Parametro 3 = Hash de Stem por Arquivos
# Parametro 4 = Hash de Stem
# Parametro 5 = Classe Stemmer da lingua escolhida
#-------------------------------------------------- 
sub stemClear {
    my $self = shift;
    my $text = $_[0];
    my $file = $_[1];
    my $hStemWord = $_[2];
    my $hStemFile = $_[3];
    my $hStem = $_[4];
    my $stem = $_[5];
    my (@text,$word,$stemWord);

    @text = split(/\s+/,$text);
    $text = "";
    
    foreach $word (@text) {
        chomp($word);
        if ($word eq "|") {
            $text .= "| "
        } else {
            $stemWord = $stem->stem($word);
            
            if (!defined($hStemWord->{$stemWord}->{$word})) {
                $hStemWord->{$stemWord}->{$word} = 1;
            } else {
                $hStemWord->{$stemWord}->{$word} += 1;
            }

            if (!defined($hStemFile->{$stemWord}->{$file})) {
                $hStemFile->{$stemWord}->{$file} = 1;
            } else {
                $hStemFile->{$stemWord}->{$file} += 1;
            }

            if (!defined($hStem->{$stemWord})) {
                $hStem->{$stemWord} = 1;
            } else {
                $hStem->{$stemWord} += 1;
            }
            
            $text .= $stemWord ." ";
        }
    }
    return $text;
}

#--------------------------------------------------
# Criação de arquivos de informação sobre o Stem
# Parametro 0 = Numero total de arquivos
# Parametro 1 = Hash de Stem por palavra
# Parametro 2 = Hash de Stem por arquivo
# Parametro 3 = Hash de Stem
#-------------------------------------------------- 
sub stemFiles {
    my $self = shift;
    my $hStemWord = $_[1];
    my $hStemFile = $_[2];
    my $hStem = $_[3];

    my $file = new IO::File;
    my $dir = $self->{config}->getDirStem();
    my ($tFiles,$tCount,$stem,$word);
   
    if (! -d $dir) {
        mkdir $dir;
    }

    #----------------------------------------------
    # Criando arquivo stemWdTF.all
    # Stem ordenado por frequencia
    #----------------------------------------------

    $file->open(">$dir/stemWdTF.all")
        || die "Can't open $dir/stemWdTF.all\n";

    $tFiles = $_[0];
    foreach $stem (sort {$hStem->{$a} <=> $hStem->{$b}} keys %{$hStem}) {
        $tCount = scalar keys %{$hStemFile->{$stem}};
        print $file "$stem : ". $hStem->{$stem} ."($tCount/$tFiles)\n";
        foreach $word (sort {$hStemWord->{$stem}->{$a} <=>
            $hStemWord->{$stem}->{$b}} keys %{$hStemWord->{$stem}}) {
            print $file "       $word:$hStemWord->{$stem}->{$word}\n";
        }
    }

    $file->close;
    
    #----------------------------------------------
    # Criando arquivo stemWdST.all
    # Stem em ordem alfabetica
    #----------------------------------------------

    $file->open(">$dir/stemWdST.all")
        || die "Can't open $dir/stemWdST.all\n";

    $tFiles = $_[0];
    foreach $stem (sort keys %{$hStem}) {
        $tCount = scalar keys %{$hStemFile->{$stem}};
        print $file "$stem : ". $hStem->{$stem} ."($tCount/$tFiles)\n";
        foreach $word (sort {$hStemWord->{$stem}->{$a} <=>
            $hStemWord->{$stem}->{$b}} keys %{$hStemWord->{$stem}}) {
            print $file "       $word:$hStemWord->{$stem}->{$word}\n";
        }
    }

    $file->close;
}

#--------------------------------------------------
# Limpeza final para tirar espaços e | multiplas
# Parametro 0 = Texto
#--------------------------------------------------
sub finalClear {
    my $self = shift;
    my $text = $_[0];
    
    #Retira | multiplos
    $text =~ s/(\s*\|)+/ \| /g;

    #Elimina espacos multiplos
    $text =~ s/\s+|\t+/ /g;

    return $text;
}

1;
