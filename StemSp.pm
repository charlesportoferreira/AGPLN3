package StemSp;

use strict;
use warnings;
use Stemmer;

use vars qw(@ISA);
@ISA = qw(Stemmer);

#--------------------------------------------------
# Construtor
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = $class->SUPER::new(@_);

    #------------------------------------------
    # Inicializa variaveis para Espanhol
    #------------------------------------------
    $self = {
        c => "[^aeiou]",    # consoante
        v => "[aeiou]",     # vogal
        C => "[^aeiou]+",   # sequencia de consoante
        V => "[aeiou]+"    # sequencia de vogal
    };

    $self->{pos2} =
    "^($self->{C})?$self->{V}$self->{C}$self->{V}$self->{C}";
    # [C]VCVC

    $self->{posV} = 
    "^($self->{v}$self->{V}$self->{c}|$self->{v}$self->{C}$self->{v}|$self->{c}$self->{c}$self->{v}|$self->{c}$self->{v}.)";
    # vVc | vCv | ccv | cv*
    
    bless $self, $class;

    return $self;
}

#--------------------------------------------------
# Seleciona a lingua que será feito stem na palavra
# Parametro 0 = Palavra
#-------------------------------------------------- 
sub run {
    my $self = shift;
    my $word = $_[0];

    return $self->espn($word);
}

#--------------------------------------------------
# Espanhol
#--------------------------------------------------

#--------------------------------------------------
# Decide que metodo a utilizar na palavra
# e retorna seu stem
# Parametro 0 = Palavra
#-------------------------------------------------- 
sub espn {
    my $self = shift;
    my $word = shift;
    my $stem;

    if (length($word) <= 3) {
        # Palavras muito pequenas retornam sem stem
        return $word;
    } else {
        # Chama subrotina pra transformar a palavra
        # em seu stem em Espanhol
        $stem = $self->stemmerSp($word);

        # Se a palavra não tem stem, checar se é um verbo
        if ($word eq $stem) {
            $stem = $self->verboSp($stem);
        }
        return $stem;
    }
}

#--------------------------------------------------
# Retira sufixos das palavras
# Parametro 0 = Palavra
#-------------------------------------------------- 
sub stemmerSp {
    my $self = shift;
    my $word = shift;
    my $stem;
    
    #----------------------------------------------
    # Retirando pronomes obliquos
    #----------------------------------------------
    if ($word =~ /(sel[ao]s?|l[aeo]s?|me|nos|se)$/o) {
        $stem = $`;
        if ($stem =~ /([iy]endo|ando|[aei]?r)$/o) {
            $stem = $`;
            if ($stem =~ /$self->{pos2}/o) {
                $word = $stem;
            }
        }
    }

    #----------------------------------------------
    # Regra 1 - Retirando plural
    #----------------------------------------------
#    if ($word =~ /eis$/) {
#        $word = $`."el";
#    } elsif ($word =~ /ais$/) {
#        $word = $`."al";
#    } elsif ($word =~ /ns$/) {
#        $word = $`."m";
#    } elsif ($word =~ /res$/) {
#        $word = $`."r";
#    }
#    if ($word =~ /([^s])s$/) {
#        $word = $`.$1;
#    }

    #----------------------------------------------
    # Regra 2, 3 e 4
    #----------------------------------------------
    if ($word =~/idade?$/) {
        $stem = $`;
        if ($stem =~ /$self->{pos2}/o) {
            $word = $stem;
            if ($word =~ /(abil|iv|ic)$/) {
                $stem = $`;
                if ($stem =~ /$self->{pos2}/o) {
                    $word = $stem;
                }
            }
        }
    }
    
    #----------------------------------------------
    # Regra 5, 7, 8 e 9
    #----------------------------------------------
    if ($word =~ /(ic[ao]s?|[ai]bles?|ismos?)$/) {
        $stem = $`;
        if ($stem =~ /$self->{pos2}/o) {
            $word = $stem;
        }

    }
    
    #----------------------------------------------
    # Regra 6 
    #----------------------------------------------
    if ($word =~ /logias?$/) {
        $stem = $`."log";
        if ($stem =~ /$self->{pos2}/o) {
            $word = $stem;
        }
    }
    
    #----------------------------------------------
    # Regra 10, 11, 12 e 13
    #----------------------------------------------
    if ($word =~ /([au]cion|[au]ciones?)$/) {
        $stem = $`;
        if ($stem =~ /$self->{pos2}/o) {
            $word = $stem;
        }
    }

    #----------------------------------------------
    # Regra 14, 15, 16, 17 e 25
    #----------------------------------------------
    if ($word =~ /(ador|ador[ae]s|os[ao]s?|istas?|anzas?)$/) {
        $stem = $`;
        if ($stem =~ /$self->{pos2}/o) {
            $word = $stem;
        }
    }
    
    #----------------------------------------------
    # Regra 18, 19 e 20
    #----------------------------------------------
    if ($word =~/([ai]mientos?|amentes?)$/) {
        $stem = $`;
        if ($stem =~ /$self->{pos2}/o) {
            $word = $stem;
            if ($word =~ /(os|ativ|iv|ad|ic)$/) {
                $stem = $`;
                if ($stem =~ /$self->{pos2}/o) {
                    $word = $stem;
                }
            }
        }
    }
    
    #----------------------------------------------
    # Regra 21 e 22
    #----------------------------------------------
    if ($word =~/mente$/) {
        $stem = $`;
        if ($stem =~ /$self->{pos2}/o) {
            $word = $stem;
            if ($word =~ /[ai]ble$/) {
                $stem = $`;
                if ($stem =~ /$self->{pos2}/o) {
                    $word = $stem;
                }
            }
        }
    }
    
    #----------------------------------------------
    # Regra 23 e 24
    #----------------------------------------------
    if ($word =~/iv[ao]s?$/) {
        $stem = $`;
        if ($stem =~ /$self->{pos2}/o) {
            $word = $stem;
            if ($word =~ /at$/) {
                $stem = $`;
                if ($stem =~ /$self->{pos2}/o) {
                    $word = $stem;
                }
            }
        }
    }

    return $word;
}

#--------------------------------------------------
# Retira sufixos de verbos em espanhol
# Parametro 0 = Palavra
#-------------------------------------------------- 
sub verboSp {
    my $self = shift;
    my $word = shift;
    my $stem;
    
    if ($word =~
        /([aei]ri*[ae][ns]*|[ai]e*n*d[ao]s*|i*[ae]is|aba[im]*o*[ns]*)$/) {
        $stem = $`;
        if ($stem=~ /^$self->{posV}/) { 
            $word=$stem;
        }  
    } elsif ($word =~ /([aei]a*mos|ia[ns]*|iese[m]*[io]*[sn]*|[aei][rs][aeo]i*[ns]*|[aei][rs][aei]a*m*[io]s)$/) { 
        $stem=$`;
        if ($stem=~ /^$self->{posV}/) {
            $word=$stem;
        } elsif ($word =~ /([aeio][srun]*)$/) {
            $stem=$`;
            if ($stem=~ /^$self->{posV}/) { 
                $word=$stem;
            }  
        }  
    } elsif ($word =~ /([aeio][osrund]*|iera[im]*o*[ns]*|[ai]stei*s*|ieron)$/) {
        $stem=$`;
        if ($stem=~ /^$self->{posV}/) { 
            $word=$stem;
        }
    }
    
    return $word;
} 

1;
