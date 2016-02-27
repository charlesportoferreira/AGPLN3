package StemPt;

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
        irregVerbPt => undef
    };

    $self->{pos2} =
    "^($self->{C})?$self->{V}$self->{C}$self->{V}$self->{C}";
    # [C]VCVC

    $self->{posV} = 
    "^($self->{v}$self->{V}$self->{c}|$self->{v}$self->{C}$self->{v}|$self->{c}$self->{c}$self->{v}|$self->{c}$self->{v}.)";
    # vVc | vCv | ccv | cv*
    
    bless $self, $class;

    $self->startVarPt();

    return $self;
}

#--------------------------------------------------
# Seleciona a lingua que será feito stem na palavra
# Parametro 0 = Palavra
#-------------------------------------------------- 
sub run {
    my $self = shift;
    my $word = $_[0];

    return $self->port($word);
}

#--------------------------------------------------
# Portugues
#-------------------------------------------------- 

#--------------------------------------------------
# Decide que metodo a utilizar na palavra
# e retorna seu stem
# Parametro 0 = Palavra
#-------------------------------------------------- 
sub port {
    my $self = shift;
    my $word = shift;
    my $stem;

    # Caso seja um verbo irregular, retorna o seu infinitivo
    $stem = $self->irregPt($word);
    
    if ($stem) {
        return $stem;
    }

    if (length($word) <= 3) {
        # Palavras muito pequenas retornam sem stem
        return $word;
    } else {
        # Chama subrotina pra transformar a palavra
        # em seu stem em Portugues
        $word = $self->basicStemPt($word);
        $stem = $self->stemmerPt($word);

        # Se a palavra não tem stem, checar se é um verbo
        if ($word eq $stem) {
            $stem = $self->verboPt($word);
        }

        return $stem;
    }
}

#--------------------------------------------------
# Inicia variaveis para portugues
#-------------------------------------------------- 
sub startVarPt {
    my $self = shift;

    %{$self->{irregVerbPt}} = (
        #DAR
        da       => 'dar',
        #dado     => 'dar', #Substantivo
        dai      => 'dar',
        dais     => 'dar',
        damos    => 'dar',
        dando    => 'dar',
        dao      => 'dar',
        dar      => 'dar',
        dara     => 'dar',
        darao    => 'dar',
        daras    => 'dar',
        dardes   => 'dar',
        darei    => 'dar',
        dareis   => 'dar',
        darem    => 'dar',
        daremos  => 'dar',
        dares    => 'dar',
        daria    => 'dar',
        dariam   => 'dar',
        dariamos => 'dar',
        darias   => 'dar',
        darieis  => 'dar',
        darmos   => 'dar',
        das      => 'dar',
        dava     => 'dar',
        davam    => 'dar',
        davamos  => 'dar',
        davas    => 'dar',
        daveis   => 'dar',
        de       => 'dar',
        deem     => 'dar',
        dei      => 'dar',
        deis     => 'dar',
        demos    => 'dar',
        der      => 'dar',
        dera     => 'dar',
        deram    => 'dar',
        deramos  => 'dar',
        deras    => 'dar',
        derdes   => 'dar',
        dereis   => 'dar',
        derem    => 'dar',
        deres    => 'dar',
        dermos   => 'dar',
        des      => 'dar',
        desse    => 'dar',
        desseis  => 'dar',
        dessem   => 'dar',
        dessemos => 'dar',
        desses   => 'dar',
        deste    => 'dar',
        destes   => 'dar',
        deu      => 'dar',
        dou      => 'dar',

        #DIZER    
        diga        => 'dizer', 
        digais      => 'dizer',
        digam       => 'dizer',
        digamos     => 'dizer',
        digas       => 'dizer',
        digo        => 'dizer',
        dira        => 'dizer',
        dirao       => 'dizer',
        diras       => 'dizer',
        direi       => 'dizer',
        direis      => 'dizer',
        diremos     => 'dizer',
        diria       => 'dizer',
        diriam      => 'dizer',
        diriamos    => 'dizer',
        dirias      => 'dizer',
        dirieis     => 'dizer',
        disse       => 'dizer',
        dissemos    => 'dizer',
        disser      => 'dizer',
        dissera     => 'dizer',
        disseram    => 'dizer',
        disseramos  => 'dizer',
        disseras    => 'dizer',
        disserdes   => 'dizer',
        dissereis   => 'dizer',
        disserem    => 'dizer',
        disseres    => 'dizer',
        dissermos   => 'dizer',
        dissesse    => 'dizer',
        dissesseis  => 'dizer',
        dissessem   => 'dizer',
        dissessemos => 'dizer',
        dissesses   => 'dizer',
        disseste    => 'dizer',
        dissestes   => 'dizer',
        dito        => 'dizer',
        diz         => 'dizer',
        dizei       => 'dizer',
        dizeis      => 'dizer',
        dizem       => 'dizer',
        dizemos     => 'dizer',
        dizendo     => 'dizer',
        dizer       => 'dizer',
        dizerdes    => 'dizer',
        dizerem     => 'dizer',
        dizeres     => 'dizer',
        dizermos    => 'dizer',
        dizes       => 'dizer',
        dizia       => 'dizer',
        diziam      => 'dizer',
        diziamos    => 'dizer',
        dizias      => 'dizer',
        dizieis     => 'dizer',

        #ESTAR
        esta         => 'estar',
        #estado       => 'estar', #Substantivo
        estai        => 'estar',
        estais       => 'estar',
        estamos      => 'estar',
        estando      => 'estar',
        estao        => 'estar',
        estar        => 'estar',
        estara       => 'estar',
        estarao      => 'estar',
        estaras      => 'estar',
        estardes     => 'estar',
        estarei      => 'estar',
        estareis     => 'estar',
        estarem      => 'estar',
        estaremos    => 'estar',
        estares      => 'estar',
        estaria      => 'estar',
        estariam     => 'estar',
        estariamos   => 'estar',
        estarias     => 'estar',
        estarieis    => 'estar',
        estarmos     => 'estar',
        estas        => 'estar',
        estava       => 'estar',
        estavam      => 'estar',
        estavamos    => 'estar',
        estavas      => 'estar',
        estaveis     => 'estar',
        esteja       => 'estar',
        estejais     => 'estar',
        estejam      => 'estar',
        estejamos    => 'estar',
        estejas      => 'estar',
        esteve       => 'estar',
        estive       => 'estar',
        estivemos    => 'estar',
        estiver      => 'estar',
        estivera     => 'estar',
        estiveram    => 'estar',
        estiveramos  => 'estar',
        estiveras    => 'estar',
        estiverdes   => 'estar',
        estivereis   => 'estar',
        estiverem    => 'estar',
        estiveres    => 'estar',
        estivermos   => 'estar',
        estivesse    => 'estar',
        estivesseis  => 'estar',
        estivessem   => 'estar',
        estivessemos => 'estar',
        estivesses   => 'estar',
        estiveste    => 'estar',
        estivestes   => 'estar',

        #FAZER
        faCa       => 'fazer', 
        faCais     => 'fazer',
        faCam      => 'fazer',
        faCamos    => 'fazer',
        faCas      => 'fazer',
        faCo       => 'fazer',
        fara       => 'fazer',
        farao      => 'fazer', #Substantivo
        faras      => 'fazer',
        farei      => 'fazer',
        fareis     => 'fazer',
        faremos    => 'fazer',
        faria      => 'fazer',
        fariam     => 'fazer',
        fariamos   => 'fazer',
        farias     => 'fazer',
        farieis    => 'fazer',
        faz        => 'fazer',
        fazei      => 'fazer',
        fazeis     => 'fazer',
        fazem      => 'fazer',
        fazemos    => 'fazer',
        fazendo    => 'fazer',
        fazer      => 'fazer',
        fazerdes   => 'fazer',
        fazerem    => 'fazer',
        fazeres    => 'fazer',
        fazermos   => 'fazer',
        fazes      => 'fazer',
        fazia      => 'fazer',
        faziam     => 'fazer',
        faziamos   => 'fazer',
        fazias     => 'fazer',
        fazieis    => 'fazer',
        feito      => 'fazer',
        fez        => 'fazer',
        fiz        => 'fazer',
        fizemos    => 'fazer',
        fizer      => 'fazer',
        fizera     => 'fazer',
        fizeram    => 'fazer',
        fizeramos  => 'fazer',
        fizeras    => 'fazer',
        fizerdes   => 'fazer',
        fizereis   => 'fazer',
        fizerem    => 'fazer',
        fizeres    => 'fazer',
        fizermos   => 'fazer',
        fizesse    => 'fazer',
        fizesseis  => 'fazer',
        fizessem   => 'fazer',
        fizessemos => 'fazer',
        fizesses   => 'fazer',
        fizeste    => 'fazer',
        fizestes   => 'fazer',

        #HAVER
        ha          => 'haver',
        haja        => 'haver',
        hajais      => 'haver',
        hajam       => 'haver',
        hajamos     => 'haver',
        hajas       => 'haver',
        hao         => 'haver',
        has         => 'haver',
        havei       => 'haver',
        havemos     => 'haver',
        havendo     => 'haver',
        haver       => 'haver',
        havera      => 'haver',
        haverao     => 'haver',
        haveras     => 'haver',
        haverdes    => 'haver',
        haverei     => 'haver',
        havereis    => 'haver',
        haverem     => 'haver',
        haveremos   => 'haver',
        haveres     => 'haver',
        haveria     => 'haver',
        haveriam    => 'haver',
        haveriamos  => 'haver',
        haverias    => 'haver',
        haverieis   => 'haver',
        havermos    => 'haver',
        havia       => 'haver',
        haviam      => 'haver',
        haviamos    => 'haver',
        havias      => 'haver',
        havido      => 'haver',
        havieis     => 'haver',
        hei         => 'haver',
        heis        => 'haver',
        hemos       => 'haver',
        houve       => 'haver',
        houvemos    => 'haver',
        houver      => 'haver',
        houvera     => 'haver',
        houveram    => 'haver',
        houveramos  => 'haver',
        houveras    => 'haver',
        houverdes   => 'haver',
        houvereis   => 'haver',
        houverem    => 'haver',
        houveres    => 'haver',
        houvermos   => 'haver',
        houvesse    => 'haver',
        houvesseis  => 'haver',
        houvessem   => 'haver',
        houvessemos => 'haver',
        houvesses   => 'haver',
        houveste    => 'haver',
        houvestes   => 'haver',

        #IR
        foi      => 'ir', #Verbo SER 
        fomos    => 'ir', #Verbo SER
        'for'    => 'ir', #Verbo SER
        #fora     => 'ir', #Adverbio #Verbo SER
        foram    => 'ir', #Verbo SER
        foramos  => 'ir', #Verbo SER
        foras    => 'ir', #Verbo SER
        fordes   => 'ir', #Verbo SER
        foreis   => 'ir', #Verbo SER
        forem    => 'ir', #Verbo SER
        fores    => 'ir', #Verbo SER
        formos   => 'ir', #Verbo SER
        fosse    => 'ir', #Verbo SER
        fosseis  => 'ir', #Verbo SER
        fossem   => 'ir', #Verbo SER
        fossemos => 'ir', #Verbo SER
        fosses   => 'ir', #Verbo SER
        foste    => 'ir', #Verbo SER
        fostes   => 'ir', #Verbo SER
        fui      => 'ir', #Verbo SER
        ia       => 'ir',
        iam      => 'ir',
        iamos    => 'ir',
        ias      => 'ir',
        ide      => 'ir',
        ides     => 'ir',
        ido      => 'ir',
        ieis     => 'ir',
        indo     => 'ir',
        ir       => 'ir',
        ira      => 'ir',
        irao     => 'ir',
        iras     => 'ir',
        irdes    => 'ir',
        irei     => 'ir',
        ireis    => 'ir',
        irem     => 'ir',
        iremos   => 'ir',
        ires     => 'ir',
        iria     => 'ir',
        iriam    => 'ir',
        iriamos  => 'ir',
        irias    => 'ir',
        irieis   => 'ir',
        irmos    => 'ir',
        va       => 'ir',
        vades    => 'ir',
        vai      => 'ir',
        vais     => 'ir',
        vamos    => 'ir',
        vao      => 'ir',
        vas      => 'ir',
        vou      => 'ir',

        #PODER
        pode       => 'poder', #Verbo PODAR 
        podei      => 'poder', #Verbo PODAR
        podeis     => 'poder', #Verbo PODAR
        podem      => 'poder', #Verbo PODAR
        podemos    => 'poder', #Verbo PODAR
        podendo    => 'poder',
        poder      => 'poder', #Substantivo
        podera     => 'poder',
        poderao    => 'poder',
        poderas    => 'poder',
        poderdes   => 'poder',
        poderei    => 'poder',
        podereis   => 'poder',
        poderem    => 'poder',
        poderemos  => 'poder',
        poderes    => 'poder',
        poderia    => 'poder',
        poderiam   => 'poder',
        poderiamos => 'poder',
        poderias   => 'poder',
        poderieis  => 'poder',
        podermos   => 'poder',
        podes      => 'poder', #Verbo PODAR
        podia      => 'poder',
        podiam     => 'poder',
        podiamos   => 'poder',
        podias     => 'poder',
        podido     => 'poder',
        podieis    => 'poder',
        possa      => 'poder',
        possais    => 'poder',
        possam     => 'poder',
        possamos   => 'poder',
        possas     => 'poder',
        posso      => 'poder',
        pude       => 'poder',
        pudemos    => 'poder',
        puder      => 'poder',
        pudera     => 'poder',
        puderam    => 'poder',
        puderamos  => 'poder',
        puderas    => 'poder',
        puderdes   => 'poder',
        pudereis   => 'poder',
        puderem    => 'poder',
        puderes    => 'poder',
        pudermos   => 'poder',
        pudesse    => 'poder',
        pudesseis  => 'poder',
        pudessem   => 'poder',
        pudessemos => 'poder',
        pudesses   => 'poder',
        pudeste    => 'poder',
        pudestes   => 'poder',

        #SABER
        sabe        => 'saber',
        sabei       => 'saber',
        sabeis      => 'saber',
        sabem       => 'saber',
        sabemos     => 'saber',
        sabendo     => 'saber',
        saber       => 'saber',
        sabera      => 'saber',
        saberao     => 'saber',
        saberas     => 'saber',
        saberdes    => 'saber',
        saberei     => 'saber',
        sabereis    => 'saber',
        saberem     => 'saber',
        saberemos   => 'saber',
        saberes     => 'saber',
        saberia     => 'saber',
        saberiam    => 'saber',
        saberiamos  => 'saber',
        saberias    => 'saber',
        saberieis   => 'saber',
        sabermos    => 'saber',
        sabes       => 'saber',
        sabia       => 'saber',
        sabiam      => 'saber',
        sabiamos    => 'saber',
        sabias      => 'saber',
        sabido      => 'saber',
        sabieis     => 'saber',
        saiba       => 'saber',
        saibais     => 'saber',
        saibam      => 'saber',
        saibamos    => 'saber',
        saibas      => 'saber',
        sei         => 'saber',
        soube       => 'saber',
        soubemos    => 'saber',
        souber      => 'saber',
        soubera     => 'saber',
        souberam    => 'saber',
        souberamos  => 'saber',
        souberas    => 'saber',
        souberdes   => 'saber',
        soubereis   => 'saber',
        souberem    => 'saber',
        souberes    => 'saber',
        soubermos   => 'saber',
        soubesse    => 'saber',
        soubesseis  => 'saber',
        soubessem   => 'saber',
        soubessemos => 'saber',
        soubesses   => 'saber',
        soubeste    => 'saber',
        soubestes   => 'saber',

        #SER
        e        => 'ser', 
        era      => 'ser',
        eram     => 'ser',
        eramos   => 'ser',
        eras     => 'ser',
        ereis    => 'ser',
        es       => 'ser',
        foi      => 'ser', #Verbo IR
        fomos    => 'ser', #Verbo IR
        'for'    => 'ser', #Verbo IR
        #fora     => 'ser', #Adverbio #Verbo IR
        foram    => 'ser', #Verbo IR
        foramos  => 'ser', #Verbo IR
        foras    => 'ser', #Verbo IR
        fordes   => 'ser', #Verbo IR
        foreis   => 'ser', #Verbo IR
        forem    => 'ser', #Verbo IR
        fores    => 'ser', #Verbo IR
        formos   => 'ser', #Verbo IR
        fosse    => 'ser', #Verbo IR
        fosseis  => 'ser', #Verbo IR
        fossem   => 'ser', #Verbo IR
        fossemos => 'ser', #Verbo IR
        fosses   => 'ser', #Verbo IR
        foste    => 'ser', #Verbo IR
        fostes   => 'ser', #Verbo IR
        fui      => 'ser', #Verbo IR
        sao      => 'ser', #Adjetivo
        se       => 'ser',
        #sede     => 'ser', #Substantivo
        seja     => 'ser',
        sejais   => 'ser',
        sejam    => 'ser',
        sejamos  => 'ser',
        sejas    => 'ser',
        sendo    => 'ser',
        ser      => 'ser',
        sera     => 'ser',
        serao    => 'ser',
        seras    => 'ser',
        serdes   => 'ser',
        serei    => 'ser',
        sereis   => 'ser',
        serem    => 'ser',
        seremos  => 'ser',
        seres    => 'ser',
        seria    => 'ser',
        seriam   => 'ser',
        seriamos => 'ser',
        serias   => 'ser',
        serieis  => 'ser',
        sermos   => 'ser',
        sido     => 'ser',
        sois     => 'ser',
        somos    => 'ser',
        sou      => 'ser',

        #TER
        tem        => 'ter', 
        temos      => 'ter',
        #tende      => 'ter', #Figurativo
        tendes     => 'ter',
        tendo      => 'ter',
        tenha      => 'ter',
        tenhais    => 'ter',
        tenham     => 'ter',
        tenhamos   => 'ter',
        tenhas     => 'ter',
        tenho      => 'ter',
        tens       => 'ter',
        ter        => 'ter',
        tera       => 'ter',
        terao      => 'ter',
        teras      => 'ter',
        terdes     => 'ter',
        terei      => 'ter',
        tereis     => 'ter',
        terem      => 'ter',
        teremos    => 'ter',
        teres      => 'ter',
        teria      => 'ter',
        teriam     => 'ter',
        teriamos   => 'ter',
        terias     => 'ter',
        terieis    => 'ter',
        termos     => 'ter',
        teve       => 'ter',
        tido       => 'ter',
        tinha      => 'ter',
        tinham     => 'ter',
        tinhamos   => 'ter',
        tinhas     => 'ter',
        tinheis    => 'ter',
        tive       => 'ter',
        tivemos    => 'ter',
        tiver      => 'ter',
        tivera     => 'ter',
        tiveram    => 'ter',
        tiveramos  => 'ter',
        tiveras    => 'ter',
        tiverdes   => 'ter',
        tivereis   => 'ter',
        tiverem    => 'ter',
        tiveres    => 'ter',
        tivermos   => 'ter',
        tivesse    => 'ter',
        tivesseis  => 'ter',
        tivessem   => 'ter',
        tivessemos => 'ter',
        tivesses   => 'ter',
        tiveste    => 'ter',
        tivestes   => 'ter',

        #VER    
        ve       => 'ver', 
        vede     => 'ver',
        vedes    => 'ver',
        veem     => 'ver',
        veja     => 'ver',
        vejais   => 'ver',
        vejam    => 'ver',
        vejamos  => 'ver',
        vejas    => 'ver',
        vejo     => 'ver',
        vemos    => 'ver',
        vendo    => 'ver',
        ver      => 'ver',
        vera     => 'ver',
        #verao    => 'ver', #Substantivo
        veras    => 'ver',
        #verdes   => 'ver', #Substantivo
        verei    => 'ver',
        vereis   => 'ver',
        verem    => 'ver',
        veremos  => 'ver',
        veres    => 'ver',
        veria    => 'ver',
        veriam   => 'ver',
        veriamos => 'ver',
        verias   => 'ver',
        verieis  => 'ver',
        vermos   => 'ver',
        ves      => 'ver',
        vi       => 'ver',
        via      => 'ver', #Substantivo
        viam     => 'ver',
        viamos   => 'ver',
        vias     => 'ver', #Substantivo
        vieis    => 'ver',
        vimos    => 'ver', #Verbo VIR
        vir      => 'ver', #Verbo VIR
        vira     => 'ver', #Verbo VIRAR #Verbo VIR
        viram    => 'ver',
        viramos  => 'ver', #Verbo VIRAR
        viras    => 'ver', #Verbo VIR
        virdes   => 'ver', #Verbo VIR
        vireis   => 'ver', #Verbo VIR
        virem    => 'ver', #Verbo VIR
        vires    => 'ver', #Verbo VIR
        virmos   => 'ver', #Verbo VIR
        visse    => 'ver',
        visseis  => 'ver',
        vissem   => 'ver',
        vissemos => 'ver',
        visses   => 'ver',
        viste    => 'ver',
        vistes   => 'ver',
        visto    => 'ver', #Verbo VESTIR
        viu      => 'ver',

        #VIR
        veio      => 'vir', 
        vem       => 'vir',
        venha     => 'vir',
        venhais   => 'vir',
        venham    => 'vir',
        venhamos  => 'vir',
        venhas    => 'vir',
        venho     => 'vir',
        vens      => 'vir',
        viemos    => 'vir',
        vier      => 'vir',
        viera     => 'vir',
        vieram    => 'vir',
        vieramos  => 'vir',
        vieras    => 'vir',
        vierdes   => 'vir',
        viereis   => 'vir',
        vierem    => 'vir',
        vieres    => 'vir',
        viermos   => 'vir',
        viesse    => 'vir',
        viesseis  => 'vir',
        viessem   => 'vir',
        viessemos => 'vir',
        viesses   => 'vir',
        vieste    => 'vir',
        viestes   => 'vir',
        vim       => 'vir',
        vimos     => 'vir', #Verbo VER
        vinde     => 'vir',
        vindes    => 'vir',
        vindo     => 'vir',
        vinha     => 'vir',
        vinham    => 'vir',
        vinhamos  => 'vir',
        vinhas    => 'vir',
        vinheis   => 'vir',
        vir       => 'vir', #Verbo VER
        vira      => 'vir', #Verbo VIRAR #Verbo VER
        virao     => 'vir',
        viras     => 'vir', #Verbo VER
        virdes    => 'vir', #Verbo VER
        virei     => 'vir',
        vireis    => 'vir', #Verbo VER
        virem     => 'vir', #Verbo VER
        viremos   => 'vir',
        vires     => 'vir', #Verbo VER
        viria     => 'vir',
        viriam    => 'vir',
        viriamos  => 'vir',
        virias    => 'vir',
        virieis   => 'vir',
        virmos    => 'vir', #Verbo VER

        #RIR
        ri       => 'rir', 
        ria      => 'rir',
        riais    => 'rir',
        riam     => 'rir',
        riamos   => 'rir',
        rias     => 'rir',
        ride     => 'rir',
        rides    => 'rir',
        rido     => 'rir',
        rieis    => 'rir',
        riem     => 'rir',
        rimos    => 'rir',
        rindo    => 'rir',
        #rio      => 'rir', #Substantivo
        rir      => 'rir',
        rira     => 'rir',
        riram    => 'rir',
        riramos  => 'rir',
        rirao    => 'rir',
        riras    => 'rir',
        rirdes   => 'rir',
        rirei    => 'rir',
        rireis   => 'rir',
        rirem    => 'rir',
        riremos  => 'rir',
        rires    => 'rir',
        riria    => 'rir',
        ririam   => 'rir',
        ririamos => 'rir',
        ririas   => 'rir',
        ririeis  => 'rir',
        rirmos   => 'rir',
        ris      => 'rir',
        risse    => 'rir',
        risseis  => 'rir',
        rissem   => 'rir',
        rissemos => 'rir',
        risses   => 'rir',
        riste    => 'rir',
        ristes   => 'rir',
        riu      => 'rir',

        #PÔR
        poe        => 'por',
        poem       => 'por',
        poes       => 'por',
        pomos      => 'por',
        ponde      => 'por',
        pondes     => 'por',
        pondo      => 'por',
        ponha      => 'por',
        ponhais    => 'por',
        ponham     => 'por',
        ponhamos   => 'por',
        ponhas     => 'por',
        ponho      => 'por',
        por        => 'por',
        pora       => 'por',
        porao      => 'por',
        poras      => 'por',
        pordes     => 'por',
        porei      => 'por',
        poreis     => 'por',
        porem      => 'por',
        poremos    => 'por',
        pores      => 'por',
        poria      => 'por',
        poriam     => 'por',
        poriamos   => 'por',
        porias     => 'por',
        porieis    => 'por',
        pormos     => 'por',
        'pos'      => 'por',
        #posto      => 'por', #Substantivo
        punha      => 'por',
        punham     => 'por',
        punhamos   => 'por',
        punhas     => 'por',
        punheis    => 'por',
        pus        => 'por',
        pusemos    => 'por',
        puser      => 'por',
        pusera     => 'por',
        puseram    => 'por',
        puseramos  => 'por',
        puseras    => 'por',
        puserdes   => 'por',
        pusereis   => 'por',
        puserem    => 'por',
        puseres    => 'por',
        pusermos   => 'por',
        pusesse    => 'por',
        pusesseis  => 'por',
        pusessem   => 'por',
        pusessemos => 'por',
        pusesses   => 'por',
        puseste    => 'por',
        pusestes   => 'por',

        #LER
        'le'     => 'ler', 
        lede     => 'ler',
        ledes    => 'ler',
        leem     => 'ler',
        leia     => 'ler',
        leiais   => 'ler',
        leiam    => 'ler',
        leiamos  => 'ler',
        leias    => 'ler',
        leio     => 'ler',
        lemos    => 'ler',
        lendo    => 'ler',
        ler      => 'ler',
        lera     => 'ler',
        leram    => 'ler',
        leramos  => 'ler',
        lerao    => 'ler',
        leras    => 'ler',
        lerdes   => 'ler',
        lerei    => 'ler',
        lereis   => 'ler',
        lerem    => 'ler',
        leremos  => 'ler',
        leres    => 'ler',
        leria    => 'ler',
        leriam   => 'ler',
        leriamos => 'ler',
        lerias   => 'ler',
        lerieis  => 'ler',
        lermos   => 'ler',
        les      => 'ler',
        lesse    => 'ler',
        lesseis  => 'ler',
        lessem   => 'ler',
        lessemos => 'ler',
        lesses   => 'ler',
        #leste    => 'ler', #Substantivo
        lestes   => 'ler',
        leu      => 'ler',
        li       => 'ler',
        lia      => 'ler',
        liam     => 'ler',
        liamos   => 'ler',
        lias     => 'ler',
        lido     => 'ler',
        lieis    => 'ler',

        #CRER
        cre       => 'crer', 
        crede     => 'crer',
        credes    => 'crer',
        creem     => 'crer',
        creia     => 'crer',
        creiais   => 'crer',
        creiam    => 'crer',
        creiamos  => 'crer',
        creias    => 'crer',
        creio     => 'crer',
        cremos    => 'crer',
        crendo    => 'crer',
        crer      => 'crer',
        crera     => 'crer',
        creram    => 'crer',
        creramos  => 'crer',
        crerao    => 'crer',
        creras    => 'crer',
        crerdes   => 'crer',
        crerei    => 'crer',
        crereis   => 'crer',
        crerem    => 'crer',
        creremos  => 'crer',
        creres    => 'crer',
        creria    => 'crer',
        creriam   => 'crer',
        creriamos => 'crer',
        crerias   => 'crer',
        crerieis  => 'crer',
        crermos   => 'crer',
        cres      => 'crer',
        cresse    => 'crer',
        cresseis  => 'crer',
        cressem   => 'crer',
        cressemos => 'crer',
        cresses   => 'crer',
        creste    => 'crer',
        crestes   => 'crer',
        creu      => 'crer',
        cri       => 'crer',
        #cria      => 'crer', #Substantivo
        criam     => 'crer',
        criamos   => 'crer',
        #crias     => 'crer', #Substantivo
        crido     => 'crer',
        crieis    => 'crer',

        #CABER
        cabe        => 'caber', 
        cabei       => 'caber',
        cabeis      => 'caber',
        cabem       => 'caber',
        cabemos     => 'caber',
        cabendo     => 'caber',
        caber       => 'caber',
        cabera      => 'caber',
        caberao     => 'caber',
        caberas     => 'caber',
        caberdes    => 'caber',
        caberei     => 'caber',
        cabereis    => 'caber',
        caberem     => 'caber',
        caberemos   => 'caber',
        caberes     => 'caber',
        caberia     => 'caber',
        caberiam    => 'caber',
        caberiamos  => 'caber',
        caberias    => 'caber',
        caberieis   => 'caber',
        cabermos    => 'caber',
        cabes       => 'caber',
        cabia       => 'caber',
        cabiam      => 'caber',
        cabiamos    => 'caber',
        cabias      => 'caber',
        cabido      => 'caber',
        cabieis     => 'caber',
        caiba       => 'caber',
        caibais     => 'caber',
        caibam      => 'caber',
        caibamos    => 'caber',
        caibas      => 'caber',
        caibo       => 'caber',
        coube       => 'caber',
        coubemos    => 'caber',
        couber      => 'caber',
        coubera     => 'caber',
        couberam    => 'caber',
        couberamos  => 'caber',
        couberas    => 'caber',
        couberdes   => 'caber',
        coubereis   => 'caber',
        couberem    => 'caber',
        couberes    => 'caber',
        coubermos   => 'caber',
        coubesse    => 'caber',
        coubesseis  => 'caber',
        coubessem   => 'caber',
        coubessemos => 'caber',
        coubesses   => 'caber',
        coubeste    => 'caber',

        #QUERER
        queira      => 'querer',
        queirais    => 'querer',
        queiram     => 'querer',
        queiramos   => 'querer',
        queiras     => 'querer',
        quer        => 'querer',
        querei      => 'querer',
        quereis     => 'querer',
        querem      => 'querer',
        queremos    => 'querer',
        querendo    => 'querer',
        querer      => 'querer',
        querera     => 'querer',
        quererao    => 'querer',
        quereras    => 'querer',
        quererdes   => 'querer',
        quererei    => 'querer',
        querereis   => 'querer',
        quererem    => 'querer',
        quereremos  => 'querer',
        quereres    => 'querer',
        quereria    => 'querer',
        quereriam   => 'querer',
        quereriamos => 'querer',
        quererias   => 'querer',
        quererieis  => 'querer',
        querermos   => 'querer',
        queres      => 'querer',
        queria      => 'querer',
        queriam     => 'querer',
        queriamos   => 'querer',
        querias     => 'querer',
        #querido     => 'querer', #Adjetivo
        querieis    => 'querer',
        quero       => 'querer',
        quis        => 'querer',
        quisemos    => 'querer',
        quiser      => 'querer',
        quisera     => 'querer',
        quiseram    => 'querer',
        quiseramos  => 'querer',
        quiseras    => 'querer',
        quiserdes   => 'querer',
        quisereis   => 'querer',
        quiserem    => 'querer',
        quiseres    => 'querer',
        quisermos   => 'querer',
        quisesse    => 'querer',
        quisesseis  => 'querer',
        quisessem   => 'querer',
        quisessemos => 'querer',
        quisesses   => 'querer',
        quiseste    => 'querer',
        quisestes   => 'querer',

        #TRAZER
        traga        => 'trazer',
        tragais      => 'trazer',
        tragam       => 'trazer', #Verbo TRAGAR
        tragamos     => 'trazer', #Verbo TRAGAR
        tragas       => 'trazer',
        trago        => 'trazer', #Verbo TRAGAR
        trara        => 'trazer',
        trarao       => 'trazer',
        traras       => 'trazer',
        trarei       => 'trazer',
        trareis      => 'trazer',
        traremos     => 'trazer',
        traria       => 'trazer',
        trariam      => 'trazer',
        trariamos    => 'trazer',
        trarias      => 'trazer',
        trarieis     => 'trazer',
        traz         => 'trazer',
        trazei       => 'trazer',
        trazeis      => 'trazer',
        trazem       => 'trazer',
        trazemos     => 'trazer',
        trazendo     => 'trazer',
        trazer       => 'trazer',
        trazerdes    => 'trazer',
        trazerem     => 'trazer',
        trazeres     => 'trazer',
        trazermos    => 'trazer',
        trazes       => 'trazer',
        trazia       => 'trazer',
        traziam      => 'trazer',
        traziamos    => 'trazer',
        trazias      => 'trazer',
        trazido      => 'trazer',
        trazieis     => 'trazer',
        trouxe       => 'trazer',
        trouxemos    => 'trazer',
        trouxer      => 'trazer',
        trouxera     => 'trazer',
        trouxeram    => 'trazer',
        trouxeramos  => 'trazer',
        trouxeras    => 'trazer',
        trouxerdes   => 'trazer',
        trouxereis   => 'trazer',
        trouxerem    => 'trazer',
        trouxeres    => 'trazer',
        trouxermos   => 'trazer',
        trouxesse    => 'trazer',
        trouxesseis  => 'trazer',
        trouxessem   => 'trazer',
        trouxessemos => 'trazer',
        trouxesses   => 'trazer',
        trouxeste    => 'trazer',
        trouxestes   => 'trazer'
    );
}

#--------------------------------------------------
# Elimina pronomes obliquos e retira plurais
# Parametro 0 = Palavra
#-------------------------------------------------- 
sub basicStemPt {
    my $self = shift;
    my $word = shift;
    
    #----------------------------------------------
    # Retira pronomes obliquos
    #----------------------------------------------
    if ($word =~ /-([nl]?[ao]s?|[mts]e|lhes?|vos)$/) {
        $word = $`;
    }
    
    #----------------------------------------------
    # Regra 1 - Retirando plural
    #----------------------------------------------
    if ($word =~ /ns$/) {
        $word = $`."m";
    } elsif ($word =~ /res$/) {
        $word = $`."r";
    } elsif ($word =~ /Coes$/) {
        $word = $`."Cao";
    }
    
    return $word;
}

#--------------------------------------------------
# Retira sufixos das palavras
# Parametro 0 = Palavra
#-------------------------------------------------- 
sub stemmerPt {
    my $self = shift;
    my $word = shift;
    my $stem;
    
    #----------------------------------------------
    # Regra 2 e 3
    #----------------------------------------------
    if ($word =~ /idades?$/) {
        $stem = $`;
        if ($stem =~ /$self->{pos2}/o) {
            $word = $stem;
            if ($word =~ /(abil|iv|ic)$/) {
                $stem = $`;
                if ($stem =~ /$self->{pos2}/) {
                    $word = $stem;
                }
            }
        }
    }
    #----------------------------------------------
    # Regra 4, 5 e 6
    #----------------------------------------------
    elsif ($word =~ /(ic[ao]s?|[ai]vel|[ai]veis|ismos?)$/) {
        $stem = $`;
        if ($stem =~ /$self->{pos2}/o) {
            $word = $stem;
        }
    }
    #----------------------------------------------
    # Regra
    #----------------------------------------------
    elsif ($word =~ /logias?/) {
        $stem = $`."log";
        if ($stem =~ /$self->{pos2}/o) {
            $word = $stem;
        }
    }
    #----------------------------------------------
    # Regra 7
    #----------------------------------------------
    elsif ($word =~ /(Coes|Cao|[ao]es)$/) {
        $stem = $`;
        if ($stem =~ /$self->{pos2}/o) {
            $word = $stem;
        }
    }
    #----------------------------------------------
    # Regra 8, 9, 10 e 17
    #----------------------------------------------
    elsif ($word =~ /(ador|ador[ae]s?|os[ao]s?|istas?|ezas?)$/) {
        $stem = $`;
        if ($stem =~ /$self->{pos2}/o) {
            $word = $stem;
        }        
    }
    #----------------------------------------------
    # Regra 11 e 12
    #----------------------------------------------
    elsif ($word =~ /([ai]mentos?|amente)$/) {
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
    # Regra 13 e 14
    #----------------------------------------------
    elsif ($word =~ /mentes?$/) {
        $stem = $`;
        if ($stem =~ /$self->{pos2}/o) {
            $word = $stem;
            if ($word =~ /(avel|ivel)$/) {
                $stem = $`;
                if ($stem =~ /$self->{pos2}/o) {
                    $word = $stem;
                }
            }
        }
    }
    #----------------------------------------------
    # Regra 15 e 16
    #----------------------------------------------
    elsif ($word=~ /(iv[ao]s?)$/) {
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
# Retira sufixos de verbos em portugues
# Parametro 0 = Palavra
#-------------------------------------------------- 
sub verboPt {
    my $self = shift;
    my $word = shift;
    my $stem;
    
    if (($word =~ /([aei][rsv]s*i*eis*|[aei]s[st]es*|[aei]rao)$/) && (($stem = $`) =~ /^$self->{posV}/o)) {
        $word = $stem;
    } elsif (($word =~ /([aei][rv]i*[aeo][ms]*|[aei][rv]*i*[ae]*mos*|[aei]ssemo*s*|ia[ms]*|[ae]is*|[aei]n*d[ao]s*)$/) && (($stem = $`) =~ /^$self->{posV}/o)) {
        $word = $stem;
    } elsif (($word =~ /[aeio][srum]*$/) && (($stem = $`) =~ /^$self->{posV}/o)) {
        $word = $stem;
    }

    return $word;
}

#--------------------------------------------------
# Transforma verbos irregulares em seus infinitivos
# Parametro 0 = Palavra
#-------------------------------------------------- 
sub irregPt {
    my $self = shift;
    my $word = shift;

    if (defined $self->{irregVerbPt}->{$word}) {
        return $self->{irregVerbPt}->{$word};
    } else {
        return 0;
    }
}

1;
