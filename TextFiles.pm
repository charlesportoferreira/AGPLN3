package TextFiles;

use strict;
use warnings;
use IO::Dirent;

#--------------------------------------------------
# Construtor 
# Parametro 0 = Diretorio
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {};

    bless $self, $class;
    
    $self->{fileNames} = ();
    $self->{fileDirs} = ();
    $self->{numTexts} = undef;
    $self->{numDirs} = undef;
    $self->{dir} = undef;
    
    $self->setDir($_[0]);
    $self->createTextFiles();
    
    return $self;
}

#--------------------------------------------------
# Indica diretorio a ser utilizado
# Parametro 0 = Diretorio
#-------------------------------------------------- 
sub setDir { 
    my $self = shift;
    my $dir = $_[0];
    if (-d $dir) {
        $self->{dir} = $dir;
    } else {
        die "Directory $dir doesn't exists. Can't define directiry of
        TextFiles: $!\n";
    }
}

#--------------------------------------------------
# Cria diretorios semelhantes ao diretorio
# principal
# Parametro 0 = Nome do novo diretorio
#-------------------------------------------------- 
sub createDir {
    my $self = shift;
    my $name = $_[0];
    my ($i,$newDir);

    mkdir $self->{dir}.'_'.$name;
    
    for ($i=0;$i<$self->{numDirs};$i++) {
        $newDir = $self->{fileDirs}[$i];
        $newDir =~ s/^$self->{dir}/$self->{dir}\_$name/;
        mkdir $newDir;
    }
}

#--------------------------------------------------
# Pega numero de textos no diretorio
#-------------------------------------------------- 
sub getNumTexts {
    my $self = shift;
    return $self->{numTexts};
}

#--------------------------------------------------
# Pega arquivo texto a ser lido
# Parametro 0 = Numero do texto dessjado
#-------------------------------------------------- 
sub getFileName {
    my $self = shift;
    return ${$self->{fileNames}}[$_[0]];
}

#--------------------------------------------------
# Pega nome dos arquivos textos a serem lidos
# Parametro 0 = Diretorio
#-------------------------------------------------- 
sub getFiles {
    my $self = shift;
    my $dir = $_[0];
    my ($totalFiles,@files,$fileName);

    opendir DIR, "$dir";
    @files = readdirent(DIR);
    closedir DIR;
        
    $totalFiles = scalar @files;    
    
    foreach $fileName (@files) {
        if (!($fileName->{name} =~ /^\.{1,2}$/)) {
            if (-d "$dir/$fileName->{name}") {
                push(@{$self->{fileDirs}},"$dir/$fileName->{name}");
                $self->getFiles("$dir/$fileName->{name}");
            } else {
                push(@{$self->{fileNames}},"$dir/$fileName->{name}");
            }
        }
    }
    
    $self->{numTexts} = scalar @{$self->{fileNames}};
    if ($self->{numTexts} != $totalFiles - 2) {
        $self->{numDirs} = scalar @{$self->{fileDirs}};
    } else {
        $self->{numDirs} = 0;
    }
}

#--------------------------------------------------
# Inicializa o pacote
#-------------------------------------------------- 
sub createTextFiles {
    my $self = shift;
    $self->getFiles($self->{dir});
}

1;
