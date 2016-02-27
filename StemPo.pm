package StemPo;

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
    # Inicializa variaveis para Portugues
    #------------------------------------------
    $self = {
        c => "[^aeiou]",    # consoante
        v => "[aeiou]",     # vogal
        C => "[^aeiou]+",   # sequencia de consoante
        V => "[aeiou]+",    # sequencia de vogal
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
   
   if ((length($word) <= 40) && ($word !~ /\d+/ )){ # ignore words with more than 40 letters and numbers
      if ($word =~ /(\-[ao]s*|\-l[ao]s*|\-se|\-lhes*|-n[ao]s*)$/o){
	  $word = $`;
      }
      return $self->port($word);     #  stemize the word
   }
}

#--------------------------------------------------
# Portugues Pretext Antigo
#-------------------------------------------------- 
sub port{
   my $self = shift;
   my $word = shift;
   my $stem;


   $stem = $self->irregPt($word);
   if ($stem){
       return $stem;
   }
   if (length($word) <= 3) {                   # length at least 3   
    return $word;
   } else {
    $stem = $self->stemmerPt($word);       # chamada para a subrotina que transforma 
                    # uma palavra em Portugues no seu stem.    
    if ($word eq $stem) {                  # fazer um 'case' para os outros idiomas       
       $stem = $self->verboPt($stem);    
    }
    return $stem; 
   } 
}

sub stemmerPt {  
   my $self = shift;
   my $stem;
   my $w = shift; 
   
 
   # Retirando os sufixos -se, -la, -lo, -los
   #-----------------------------------------
#   if ($w =~ /(\[ao]s*|\-l[ao]s*|\-se|\-lhes*|-n[ao]s*)$/o) 
 #  {
  #    $stem = $`; 
   #   if ($stem =~ /$pos2/o) 
    #  { 
     #    $w = $stem; 
      #}
#   }

   # Regra 1                         # retirando plural
   #---------------------------------------------------
#   if    ($w =~ /(ei)s$/)   { $w=$`."el"; }
 #  elsif ($w =~ /(ai)s$/)   { $w=$`."al"; }
   if ($w =~ /ns$/)    { $w=$`."m"; }
   elsif ($w =~ /res$/){ $w=$`."r"; }
   #elsif ($w =~ /[^s]s$/) { $w=$`.$1; }

   # Regra 2 e 3
   #------------
   if ($w =~ /idades*$/) {  
      $stem = $`;
      if ($stem =~ /$self->{pos2}/o) {
         $w = $stem;
         if ($w =~ /(abil|iv|ic)$/) { 
            $stem= $`;
            if ($stem =~ /$self->{pos2}/) { 
               $w = $stem; 
            }
         }    
      }
   }
  
   # Regra 4, 5 e 6
   #---------------
   elsif ($w =~ /(ic[ao]s*|[ai]vel|[ai]veis|ismos*)$/) {
      $stem = $`;
      if ($stem =~ /$self->{pos2}/o) { 
         $w = $stem;
      }
   }

   # Regra 
   #---------------
  elsif ($w =~ /logias*$/) {
     $stem = $`."log";
     if ($stem =~ /$self->{pos2}/o) { 
        $w = $stem;
     }
  }
  
  # Regra 7
  #--------
  elsif ($w =~ /(ç[o]es|ç[a]o|[ao]es)$/) {
     $stem = $`;
     if ($stem =~ /$self->{pos2}/o) { 
        $w = $stem;
     }
  }

  # Regra 8, 9, 10 e 17
  #--------------------
  elsif ($w =~ /(ador|ador[ae]s*|os[ao]s*|istas*|ezas*)$/) {
     $stem = $`;
     if ($stem =~ /$self->{pos2}/o) { 
        $w = $stem;
     }
  }

  # Regra 11 e 12
  #--------------
  elsif ($w =~ /(amentos*|imentos*|amente)$/) {
     $stem = $`;
     if ($stem =~ /$self->{pos2}/o) {
        $w = $stem;
        if ($w =~ /(os|ativ|iv|ad|ic)$/) { 
           $stem = $`;
           if ($stem =~ /$self->{pos2}/o) { 
              $w = $stem; 
           }
        }    
     }
  }

  # Regra 13 e 14 
  #--------------
  elsif ($w =~ /mentes*$/) {
     $stem = $`;
     if ($stem =~ /$self->{pos2}/o) {
        $w = $stem; 
        if ($w =~ /(avel|ivel|)$/) { 
           $stem= $`;
           if ($stem =~ /$self->{pos2}/o) { 
              $w = $stem; 
           }
        }    
     }
  }

  # Regra 15 e 16
  #--------------
  elsif ($w =~ /(iv[ao]s*)$/) { 
     $stem = $`;
     if ($stem =~ /$self->{pos2}/o) {
        $w = $stem;
        if ($w =~ /(at)$/) { 
           $stem= $`;
           if ($stem =~ /$self->{pos2}/o) { 
              $w = $stem; 
           }
        }    
     }
  }
   return $w;
}                


sub verboPt{  
   my $self = shift;
   my $w = shift;
   my $a;   

   if ($w =~ /([aei][rsv]s*[i]*eis*|[aei]s[st]es*|[aei]rao)$/) {
      $a=$`;
      if ($a=~ /^$self->{posV}/o) { 
          $w=$a;
      }  
   } 
   elsif ($w =~ /([aei][rv]i*[aeo][ms]*|[aei][rv]*[i]*[ae]*mos*|[aei]ssemo*s*|ia[ms]*|[ae]is*|[aei]n*d[ao]s*)$/) { 
      $a=$`;
      if ($a=~ /^$self->{posV}/o) {
         $w=$a;
      }
      elsif ($w =~ /([aeio][srum]*)$/) {
         $a=$`;
         if ($a=~ /^$self->{posV}/o) { 
            $w=$a;
         }  
      }  
   }
   elsif ($w =~ /([aeio][srum]*)$/) {
      $a=$`;
      if ($a=~ /^$self->{posV}/o) { 
         $w=$a;
      }  
   }
     
   return $w;
}


sub irregPt {
   my(@dar,@diz,@est,@faz,@hav,@ir,@pod,@sab,@ser,@ter,@ver,@vir);
   my $self = shift;
   my $w=shift;
  



 
   @dar=qw(dar dou da damos dao dei deu demos deram dera deramos de deem desse dessemos dessem der dermos derem);
   @diz=qw(dizer digo diz diziam dizia dizendo dizemos dizem disse dissemos disseram dissera disseramos direi dira diremos dirao diria diriamos diriam);
   @est=qw(estar estou esta estamos estao estive esteve estivemos estiveram estava estavamos estavam estivera estiveramos esteja estejamos estejam estivesse estivessemos estivessem estiver estivermos estiverem estaria);
   @faz=qw(fazer faço faz fez farei fara faremos farao faria fariamos fariam faça façamos façam);
   @hav=qw(haver havia hei ha hao haja hajamos hajam houve houvesse);  
   @ir =qw(ir vou vai vamos vao foi);
   @pod=qw(poder posso pode possa possamos possam);
   @sab=qw(saber sei saiba saibamos saibam);
   @ser=qw(ser sou somos sao era eramos eram fui foi fomos foram fora foramos seja sejamos sejam fosse fossemos fossem for formos forem serei sera seremos serao seria seriamos seriam);
   @ter=qw(ter tenho tem temos tem tinha tinhamos tinham tive teve tivemos tiveram tivera tiveramos tenha tenhamos tenham tivesse tivessemos tivessem tiver tivermos tiverem terei tera termos terao teria teriamos teriam);
   @ver=qw(ver vejo ve vemos veem vi viu viram vira viramos veja vejamos vejam visse vissemos vissem vir virmos virem verei vera veremos verao veria veriamos veriam);
   @vir=qw(vir venho vem vimos vem vinha vinhamos vinham vim veio viemos vieram viera vieramos venha venhamos venham viesse viessemos viessem vier viermos vierem virei vira viremos virao viria viriamos viriam);

   if    (grep /^$w$/, @dar) {return 'dar';}
   elsif (grep /^$w$/, @diz) {return 'diz';}  
   elsif (grep /^$w$/, @est) {return 'est';}  
   elsif (grep /^$w$/, @faz) {return 'faz';}  
   elsif (grep /^$w$/, @hav) {return 'hav';}
   elsif (grep /^$w$/, @ir)  {return 'ir';}
   elsif (grep /^$w$/, @pod) {return 'pod';}
   elsif (grep /^$w$/, @sab) {return 'sab';}
   elsif (grep /^$w$/, @ser) {return 'ser';}
   elsif (grep /^$w$/, @ter) {return 'ter';}
   elsif (grep /^$w$/, @ver) {return 'ver';}
   elsif (grep /^$w$/, @vir) {return 'vir';}
   else { return 0; }
}

1;
