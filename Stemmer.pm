package Stemmer;

use strict;
use warnings;

#--------------------------------------------------
# Construtor
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {};

    bless $self, $class;

    return $self;
}

#--------------------------------------------------
# Seleciona a lingua que será feito stem na palavra
# Parametro 0 = Palavra
#-------------------------------------------------- 
sub stem {
    my $self = shift;
    my $word = $_[0];

    return $self->run($word);
}

1;
