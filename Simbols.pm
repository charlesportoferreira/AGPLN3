package Simbols;

use strict;
use warnings;
use XML::Parser;

#--------------------------------------------------
# Contrutor
#-------------------------------------------------- 
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
        clearall => undef,
        simbolWb => "",
        simbolNb => ""
    };
        
    bless $self, $class;

    $self->readFile();
    
    return $self;
}

#--------------------------------------------------
# Retorna ClearAll
#-------------------------------------------------- 
sub getClearAll {
    my $self = shift;

    return $self->{clearall};
}

#--------------------------------------------------
# Retorna Simbolos com Break
#-------------------------------------------------- 
sub getSimbolWithBreak {
    my $self = shift;

    return $self->{simbolWb};
}

#--------------------------------------------------
# Retorna Simbolos sem Break
#-------------------------------------------------- 
sub getSimbolWithoutBreak {
    my $self = shift;

    return $self->{simbolNb};
}

#--------------------------------------------------
# Le Simbolos e armazena em duas hash
#-------------------------------------------------- 
sub readFile {
    my $self = shift;
    my $i;
    my $parser = XML::Parser->new(Style => 'Tree');
    my $tree = $parser->parsefile('simbols.xml');

    @{$tree}[0] eq "simbols" || die "XML Simbols File not valid!\n";
    my $simbols = @{$tree}[1];

    if (defined @{$simbols}[0]->{clearall}) {
        if ((uc(@{$simbols}[0]->{clearall}) eq "TRUE") ||
            (uc(@{$simbols}[0]->{clearall}) eq "FALSE")) {
            $self->{clearall} = uc(@{$simbols}[0]->{clearall});
        } else {
            die "XML Simbols - Option ClearAll Invalid\n";
        }
    } else {
        $self->{clearall} = "TRUE";
    }

    $i = 3;

    while ((defined @{$simbols}[$i]) && (@{$simbols}[$i] eq "simbol")) {
        if (defined @{@{$simbols}[$i+1]}[0]->{break}) {
            if (uc(@{@{$simbols}[$i+1]}[0]->{break}) eq "TRUE") {
                $self->{simbolWb} .= "\\". @{@{$simbols}[$i+1]}[2];
            } elsif (uc(@{@{$simbols}[$i+1]}[0]->{break}) eq "FALSE") {
                $self->{simbolNb} .= "\\". @{@{$simbols}[$i+1]}[2];
            } else {
                die "XML Simbols - Option Break Invalid\n";
            }
        } else {
            $self->{simbolNb} .= "\\". @{@{$simbols}[$i+1]}[2];
        }
        $i += 4;
    }

    if ($self->{simbolWb} eq "") {
        $self->{simbolWb} = "\\:\\|";
    }

    if ($self->{simbolNb} eq "") {
        $self->{simbolNb} = "\\_\\-";
    }
}

1;
