package StemEn;

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
    # Inicializa variaveis Ingles
    #------------------------------------------
    $self = {
        c => "[^aeiou]",    # consoant
        v => "[aeiouy]",    # vowel
        C => "[^aeiouy]+",  # consonant sequence
        V => "[aeiou]+",    # vowel sequence
        step2list => undef,
        step3list => undef
    };
        
    $self->{mgr0} =
    "^($self->{C})?$self->{V}$self->{C}";
    # [C]VC     is m > 0
        
    $self->{meq1} =
    "^($self->{C})?$self->{V}$self->{C}($self->{V})?".'$';
    # [C]VC[V]  is m = 1

    $self->{mgr1} =
    "^($self->{C})?$self->{V}$self->{C}$self->{V}$self->{C}";
    # [C]VCVC   is m > 1
        
    $self->{_v} = "^($self->{C})?$self->{v}";
    # vowel in stem
    
    bless $self, $class;
    
    $self->_load_hash();

    return $self;
}

#--------------------------------------------------
# Seleciona a lingua que será feito stem na palavra
# Parametro 0 = Palavra
#-------------------------------------------------- 
sub run {
    my $self = shift;
    my $word = $_[0];

    return $self->engl($word);
}

#--------------------------------------------------
# Ingles
#--------------------------------------------------

#--------------------------------------------------
# Porter, 1980, An algorithm for suffix stripping,
# Program, Vol. 14, no. 3, pp 130-137,
#
# see also
# http://www.tartarus.org/~martin/PorterStemmer
#-------------------------------------------------- 
sub engl{
    my $self = shift;
    my ($stem, $suffix, $firstch);
    my $word = shift;
    my %step2list = %{$self->{step2list}};
    my %step3list = %{$self->{step3list}};
    my $c         = $self->{c};
    my $v         = $self->{v};
    my $C         = $self->{C};
    my $V         = $self->{V};
    my $mgr0      = $self->{mgr0};
    my $meq1      = $self->{meq1};
    my $mgr1      = $self->{mgr1};
    my $_v        = $self->{_v};
   
    if (length($word) < 3) {
        return $word;
    } # length at least 3
    
    # now map initial y to Y so that the patterns never treat it as vowel:
    $word =~ /^./;
    $firstch = $&;
    
    if ($firstch =~ /^y/) {
        $word = ucfirst $word;
    }

    # Step 1a
    if ($word =~ /(ss|i)es$/) {
        $word=$`.$1;
    } elsif ($word =~ /([^s])s$/) {
        $word=$`.$1;
    }
    
    # Step 1b
    if ($word =~ /eed$/) {
        if ($` =~ /$mgr0/o) {
            chop($word);
        }
    } elsif ($word =~ /(ed|ing)$/) {
        $stem = $`;
        if ($stem =~ /$_v/o) {
            $word = $stem;
            if ($word =~ /(at|bl|iz)$/) {
                $word .= "e";
            } elsif ($word =~ /([^aeiouylsz])\1$/) {
                chop($word);
            } elsif ($word =~ /^${C}${v}[^aeiouwxy]$/o) {
                $word .= "e";
            }
        }
    }
    
    # Step 1c
    if ($word =~ /y$/) {
        $stem = $`;
        if ($stem =~ /$_v/o) {
            $word = $stem."i";
        }
    }

    # Step 2
    if ($word =~ /(ational|tional|enci|anci|izer|bli|alli|entli|eli|ousli|ization|ation|ator|alism|iveness|fulness|ousness|aliti|iviti|biliti|logi)$/)
    {
        $stem = $`;
        $suffix = $1;
        if ($stem =~ /$mgr0/o) {
            $word = $stem . $step2list{$suffix};
        }
    }

    # Step 3
    if ($word =~ /(icate|ative|alize|iciti|ical|ful|ness)$/) {
        $stem = $`;
        $suffix = $1;
        if ($stem =~ /$mgr0/o) {
            $word = $stem . $step3list{$suffix};
        }
    }

    # Step 4
    if ($word =~ /(al|ance|ence|er|ic|able|ible|ant|ement|ment|ent|ou|ism|ate|iti|ous|ive|ize)$/)
    {
        $stem = $`; if ($stem =~ /$mgr1/o) {
            $word = $stem;
        }
    } elsif ($word =~ /(s|t)(ion)$/) {
        $stem = $` . $1;
        if ($stem =~ /$mgr1/o) {
            $word = $stem;
        }
    }

    #  Step 5
    if ($word =~ /e$/) {
        $stem = $`;
        if ($stem =~ /$mgr1/o or
            ($stem =~ /$meq1/o and not $stem =~ /^${C}${v}[^aeiouwxy]$/o)) {
            $word = $stem;
        }
    }
    if ($word =~ /ll$/ and $word =~ /$mgr1/o) {
        chop($word);
    }

    # and turn initial Y back to y
    if ($firstch =~ /^y/) {
        $word = lcfirst $word;
    }
    
    return $word;   
}

#--------------------------------------------------
# Inicia variaveis para ingles
#-------------------------------------------------- 
sub _load_hash {
    my $self = shift;

    %{$self->{step2list}} = (
        ational => 'ate',
        tional  => 'tion',
        enci    => 'ence',
        anci    => 'ance',
        izer    => 'ize',
        bli     => 'ble',
        alli    => 'al',
        entli   => 'ent',
        eli     => 'e',
        ousli   => 'ous',
        ization => 'ize',
        ation   => 'ate',
        ator    => 'ate',
        alism   => 'al',
        iveness => 'ive',
        fulness => 'ful',
        ousness => 'ous',
        aliti   => 'al',
        iviti   => 'ive',
        biliti  => 'ble',
        logi    => 'log'
    );
    
    %{$self->{step3list}} = (
        icate => 'ic',
        ative => '',
        alize => 'al',
        iciti => 'ic',
        ical  => 'ic',
        ful   => '',
        ness  => ''
    );
}

1;
