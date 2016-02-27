package StemAz;

use strict;
use warnings;
use Stemmer;

use vars qw(@ISA);
@ISA = qw(Stemmer);

use Lingua::Stem;
use Data::Dumper;

#--------------------------------------------------
# Construtor
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = $class->SUPER::new(@_);
    
    bless $self, $class;

    return $self;
}

#--------------------------------------------------
# Seleciona a lingua que será feito stem na palavra
# Parametro 0 = Palavra
#-------------------------------------------------- 
sub run {
    my $self = shift;
    my @word = ($_[0]);
    my %exceptions;

    my $word = Lingua::Stem::Pt::stem({ -words => \@word, -locale => 'pt', -exceptions => \%exceptions });
    return pop(@{$word});
}


1;
