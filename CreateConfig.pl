#!/usr/bin/perl

package CreateConfig;

use strict;
use warnings;
use Data::Dumper;
use IO::File;

main();

#--------------------------------------------------
# Funcao principal
#-------------------------------------------------- 
sub main {
    my $option;
    my $xml = {
        #opcoes gerais
        general => {
            lang      => "",
            dir       => "",
            'log'     => "",
            silence   => ""
        },
        #opcoes do maid
        maid    => {
            set       => "",
            number    => "",
            html      => "",
            simbols   => "",
            stoplist  => {
                set       => "",
                dir       => "",
                stopfiles => undef
            },
            stemming  => {
                set       => "",
                dir       => ""
            }
        },
        #opcoes do ngram
        ngram   => {
            set       => "",
            dir       => "",
            gram      => undef
        },
        #opcoes do report
        report  => {
            set       => "",
            ngramdir  => "",
            discover  => "",
            graphics  => "",
            taxonomy  => "",
            transpose => "",
            gram      => undef
        }
    };

    print "\n#-----------------------------#\n";
    print "#           PreTexT           #\n";
    print "#                             #\n";
    print "#    Implemented by LABIC     #\n";
    print "#-----------------------------#\n";
    print "\n";

    do {
        printGeneralOptions();
        $option = <STDIN>;
        chomp($option);
        if ($option !~ /[0-9]+/) {
            $option = 99;
        } elsif ($option == 1) {
            setPreTexTOptions($xml->{general});
        } elsif ($option == 2) {
            setMaidOptions($xml->{maid});
        } elsif ($option == 3) {
            setNgramOptions($xml->{ngram});
        } elsif ($option == 4){
            setReportOptions($xml->{report});
        } elsif ($option == 5) {
            print "\n".createConfigFile($xml)."\n";
        } elsif ($option == 6) {
            writeXML(createConfigFile($xml));
        }
    } while ($option != 0);
}

#--------------------------------------------------
# Configura as opcoes gerais do PreTexT
# Parametro 0 = Hash de configuracoes gerais
#--------------------------------------------------
sub setPreTexTOptions {
    my $option;
    my $xml = $_[0];

    do {
        printPreTexTOptions();
        $option = <STDIN>;
        chomp($option);
        if ($option !~ /[0-9]+/) {
            $option = 99;
        } elsif ($option == 1) {
            $xml->{lang} = setString($xml->{lang},"Language",1);
        } elsif ($option == 2) {
            $xml->{dir} = setString($xml->{dir},"Directory",0);
        } elsif ($option == 3) {
            $xml->{'log'} = setString($xml->{'log'},"Log File",0);
        } elsif ($option == 4){
            $xml->{silence} = setEnabled($xml->{silence},"Silence");
        }
    } while ($option != 0);
   
    printDefaultOptions($xml->{lang},"Language");
    print "Directory: $xml->{dir}\n";
    printDefaultOptions($xml->{'log'},"Log File");
    printDefaultOptions($xml->{silence},"Silence");
}

#--------------------------------------------------
# Configura as opcoes do modulo Maid.pm
# Parametro 0 = Hash de configuracoes do maid
#--------------------------------------------------
sub setMaidOptions {
    my $option;
    my $xml = $_[0];

    do {
        printMaidOptions();
        $option = <STDIN>;
        chomp($option);
        if ($option !~ /[0-9]+/) {
            $option = 99;
        } elsif ($option == 1) {
            $xml->{set} = setEnabled($xml->{set},"Maid");
        } elsif ($option == 2) {
            $xml->{number} = setEnabled($xml->{number},"Number");
            $xml->{set} = "on";
        } elsif ($option == 3) {
            $xml->{html} = setEnabled($xml->{html},"HTML");
            $xml->{set} = "on";
        } elsif ($option == 4) {
            $xml->{simbols} = setEnabled($xml->{simbols},"Simbols");
            $xml->{set} = "on";
        } elsif ($option == 5) {
            $xml->{stoplist}->{set} =
                setEnabled($xml->{stoplist}->{set},"Stoplist");
            if ($xml->{stoplist}->{set} eq "on") {
                $xml->{stoplist}->{dir} = 
                    setString($xml->{stoplist}->{dir},"Directory",0);
                $xml->{stoplist}->{stopfiles} =
                    setMany($xml->{stoplist}->{stopfiles},"Stopfile Name",0,0);
            }
            $xml->{set} = "on";
        } elsif ($option == 6){
            $xml->{stemming}->{set} =
                setEnabled($xml->{stemming}->{set},"Stemming");
            if ($xml->{stemming}->{set} eq "on") {
                $xml->{stemming}->{dir} = 
                    setString($xml->{stemming}->{dir},"Directory",0);
            }
            $xml->{set} = "on";
        }
    } while ($option != 0);
   
    print "Maid: $xml->{set}\n";

    if ($xml->{set} eq "on") {
        printDefaultOptions($xml->{number},"Number");
        printDefaultOptions($xml->{html},"HTML");
        printDefaultOptions($xml->{simbols},"Simbols");
        printDefaultOptions($xml->{stoplist}->{set},"Stoplist");
        if ($xml->{stoplist}->{set} eq "on") {
            printDefaultOptions($xml->{stoplist}->{dir}," > Directory");
            printManyOptions($xml->{stoplist}->{stopfiles}," > Stopfile Name");
        }
        printDefaultOptions($xml->{stemming}->{set},"Stemming");
        if ($xml->{stemming}->{set} eq "on") {
            printDefaultOptions($xml->{stemming}->{dir}," > Directory");
        }
    }
}

#--------------------------------------------------
# Configura as opcoes do modulo NGram.pm
# Parametro 0 = Hash de configuracoes ngram
#--------------------------------------------------
sub setNgramOptions {
    my $option;
    my $xml = $_[0];

    do {
        printNgramOptions();
        $option = <STDIN>;
        chomp($option);
        if ($option !~ /[0-9]+/) {
            $option = 99;
        } elsif ($option == 1) {
            $xml->{set} = setEnabled($xml->{set},"NGram");
        } elsif ($option == 2) {
            $xml->{dir} =
                setString($xml->{dir},"Directory",0);
            $xml->{set} = "on";
        } elsif ($option == 3) {
            $xml->{gram} = setMany($xml->{gram},"N of Gram",1,0);
            $xml->{set} = "on";
        }
    } while ($option != 0);

    print "NGram: $xml->{set}\n";

    if ($xml->{set} eq "on") {
        printDefaultOptions($xml->{dir}," > Directory");
        printManyOptions($xml->{gram}," > N of Gram");
    }
}

#--------------------------------------------------
# Configura as opcoes do modulo Report.pm
# Parametro 0 = Hash de configuracoes report
#--------------------------------------------------
sub setReportOptions {
    my $option;
    my $n;
    my $xml = $_[0];

    do {
        printReportOptions();
        $option = <STDIN>;
        chomp($option);
        if ($option !~ /[0-9]+/) {
            $option = 99;
        } elsif ($option == 1) {
            $xml->{set} = setEnabled($xml->{set},"Report");
        } elsif ($option == 2) {
            $xml->{ngramdir} =
                setString($xml->{ngramdir},"Directory NGram",0);
            $xml->{set} = "on";
        } elsif ($option == 3) {
            $xml->{discover} =
                setString($xml->{discover},"Directory Discover",0);
            $xml->{set} = "on";
        } elsif ($option == 4) {
            $xml->{graphics} =
                setString($xml->{graphics},"Directory Graphics",0);
            $xml->{set} = "on";
        } elsif ($option == 5) {
            $xml->{taxonomy} =
                setString($xml->{taxonomy},"Taxonomy File",0);
            $xml->{set} = "on";
        } elsif ($option == 6) {
            $xml->{transpose} =
                setEnabled($xml->{transpose},"Transpose Matrix");
            $xml->{set} = "on";
        } elsif ($option == 7) {
            #vario n gram aqui!
            $xml->{gram} = setMany($xml->{gram},"N of Gram",0,1);
            $xml->{set} = "on";
        }
    } while ($option != 0);

    print "Report: $xml->{set}\n";

    if ($xml->{set} eq "on") {
        printDefaultOptions($xml->{ngramdir},"Directory NGram");
        printDefaultOptions($xml->{discover},"Directory Discover");
        printDefaultOptions($xml->{graphics},"Directory Graphics");
        printDefaultOptions($xml->{taxonomy},"Taxonomy File");
        printDefaultOptions($xml->{transpose},"Transpose");

        foreach $n (keys %{$xml->{gram}}) {
            print " > N-Gram: $n\n";
            foreach $option (keys %{$xml->{gram}->{$n}}) {
                print "   $option: $xml->{gram}->{$n}->{$option}\n";
            }
        }
    }
}

#--------------------------------------------------
# Configura as opcoes especificas de cada N-gram
# utilizado no Report.pm
# Parametro 0 = Hash de configuracoes de gram
#--------------------------------------------------
sub setReportNgram {
    my $option;
    my $gram = $_[0];
    my $n    = $_[1];
    my $advance;
    
    $advance = setEnabled($advance,"Advance N-Gram Configuration?");

    if ($advance eq "on") {
        do {
            printReportNgramOptions();
            $option = <STDIN>;
            chomp($option);
            if ($option !~ /[0-9]+/) {
                $option = 99;
            } elsif ($option == 1) {
                $gram->{$n}->{max} =
                    setString($gram->{$n}->{max},"Max Limit",0);
            } elsif ($option == 2) {
                $gram->{$n}->{min} =
                    setString($gram->{$n}->{min},"Min Limit",0);
            } elsif ($option == 3) {
                $gram->{$n}->{maxfiles} =
                    setString($gram->{$n}->{maxfiles},"Max Documents",0);
            } elsif ($option == 4) {
                $gram->{$n}->{minfiles} =
                    setString($gram->{$n}->{minfiles},"Min Documents",0);
            } elsif ($option == 5) {
                $gram->{$n}->{std_dev} =
                    setString($gram->{$n}->{std_dev},
                              "Standard Deviation Cut",0);
            } elsif ($option == 6) {
                $gram->{$n}->{measure} =
                    setString($gram->{$n}->{measure},"Measure Name",0);
                $gram->{$n}->{smooth} =
                    setEnabled($gram->{$n}->{smooth},"Smooth");
            } elsif ($option == 7) {
                $gram->{$n}->{normalize} =
                    setString($gram->{$n}->{normalize},"Normalize",0);
                $gram->{$n}->{normalizetype} =
                    setEnabled($gram->{$n}->{normalizetype},
                               "Normalize Column Type");
            }
        } while ($option != 0);
    }
}

#--------------------------------------------------
# Configura uma opcao por on/off
# Parametro 0 = Variavel a ser configurada
# Parametro 1 = Texto explicativo
#--------------------------------------------------
sub setEnabled {
    my $var     = $_[0];
    my $message = $_[1];
    
    do {
        print "$message (on/off): ";
        $var = <STDIN>;
        chomp($var);
        $var = lc($var);
    } while !(($var eq "on") || ($var eq "off"));

    print "$message OK!\n";

    return $var;
}

#--------------------------------------------------
# Configura uma opcao por uma string
# Parametro 0 = Variavel a ser configurada
# Parametro 1 = Texto explicativo
# Parametro 2 = valor 1 caso seja necessario a
#               utilizacao de minusculas
#--------------------------------------------------
sub setString {
    my $var     = $_[0];
    my $message = $_[1];
    my $lc      = $_[2];

    print "$message (ENTER for nothing): ";
    $var = <STDIN>;
    chomp($var);
    if ($lc == 1) {
        $var = lc($var);
    }
    print "$message OK!\n";

    return $var;
}

#--------------------------------------------------
# Configura uma opção com vários parametros
# Parametro 0 = Variavel a ser configurada
# Parametro 1 = Texto explicativo
# Parametro 2 = valor 1 caso somente numeros possam
#               ser adicionados
# Parametro 3 = valor 1 caso a funcao tenha sido
#               chamada pelo report
#--------------------------------------------------
sub setMany {
    my $var     = $_[0];
    my $message = $_[1];
    my $number  = $_[2];
    my $report  = $_[3];
    my $stdin   = "";

    do {
        print "$message (ENTER for finish): ";
        $stdin = <STDIN>;
        chomp($stdin);
        if (($number == 1) && ($stdin !~ /[0-9]+/) && ($stdin ne "")) {
            print "Only numbers!\n"
        } elsif ($stdin ne "") {
            $var->{$stdin} = undef;
            if ($report == 1) {
                setReportNgram($var,$stdin);
            }
        }
    } while ($stdin ne "");

    return $var;
}

#--------------------------------------------------
# Imprime valor da opcao que possui valor defaulf
# Parametro 0 = Variavel da opcao
# Parametro 1 = Texto explicativo
#--------------------------------------------------
sub printDefaultOptions {
    my $var     = $_[0];
    my $message = $_[1];

    if ($var ne "") {
        print "$message: $var\n";
    } else {
        print "$message: Default\n";
    }
}

#--------------------------------------------------
# Imprime valor das opcoes com muitos parametros
# Parametro 0 = Variavel da opcao
# Parametro 1 = Texto explicativo
#--------------------------------------------------
sub printManyOptions {
    my $var     = $_[0];
    my $message = $_[1];
    my $option  = "";

    foreach $option (keys %$var) {
        print "$message: $option\n";
    }
}

#--------------------------------------------------
# Imprime Opcoes Gerais
#-------------------------------------------------- 
sub printGeneralOptions {
    print "\n1 - PreTexT General Options\n";
    print "2 - Maid Options\n";
    print "3 - Ngram Options\n";
    print "4 - Report Options\n";
    print "5 - View New Config File\n";
    print "6 - Save\n";
    print "0 - Quit\n";
    print "\n>>";
}

#--------------------------------------------------
# Imprime Opcoes do PreTexT
#-------------------------------------------------- 
sub printPreTexTOptions {
    print "\n1 - Set Language\n";
    print "2 - Set Main Directory\n";
    print "3 - Set Log File Name\n";
    print "4 - Use Silence\n";
    print "0 - Back\n";
    print "\n>>";
}

#--------------------------------------------------
# Imprime Opcoes do Maid
#-------------------------------------------------- 
sub printMaidOptions {
    print "\n1 - Use Maid\n";
    print "2 - Use Number\n";
    print "3 - Use HTML\n";
    print "4 - Use Simbols\n";
    print "5 - Set Stoplist\n";
    print "6 - Use Stemming\n";
    print "0 - Back\n";
    print "\n>>";
}

#--------------------------------------------------
# Imprime Opcoes do Ngram
#-------------------------------------------------- 
sub printNgramOptions {
    print "\n1 - Use NGram\n";
    print "2 - Set Directory\n";
    print "3 - Set N of Gram\n";
    print "0 - Back\n";
    print "\n>>";
}

#--------------------------------------------------
# Imprime Opcoes do Report
#-------------------------------------------------- 
sub printReportOptions {
    print "\n1 - Use Report\n";
    print "2 - Set Ngram Directory\n";
    print "3 - Set Discover Directory\n";
    print "4 - Set Graphics Directory\n";
    print "5 - Set Taxonomy File Name\n";
    print "6 - Use Transpose\n";
    print "7 - Set N of Gram\n";
    print "0 - Back\n";
    print "\n>>";
}

#--------------------------------------------------
# Imprime Opcoes do Report para cada N-Gram
#-------------------------------------------------- 
sub printReportNgramOptions {
    print "\n1 - Set Max Limit\n";
    print "2 - Set Min Limit\n";
    print "3 - Set Max Documents\n";
    print "4 - Set Min Documents\n";
    print "5 - Set Standard Deviation Cut\n";
    print "6 - Set Measure\n";
    print "7 - Set Normalize\n";
    print "0 - Back to Set N of Gram\n";
    print "\n>>";
}

sub createConfigFile {
    my $xml = $_[0];
    my $option;
    my $n;
    my $count;

    my $config = '<?xml version="1.0" encoding="utf-8"?>'."\n";

    $config .= '<pretext'."\n";
    $config .= '    lang="'.$xml->{general}->{lang}.'"'."\n";
    $config .= '    dir="'.$xml->{general}->{dir}.'"'."\n";
    if ($xml->{general}->{'log'} ne "") {
        $config .= '    log="'.$xml->{general}->{'log'}.'"'."\n";
    }
    if ($xml->{general}->{silence} eq "on") {
        $config .= '    silence="on"'."\n";
    }
    chomp($config);
    $config .= '>'."\n\n";

    #Maid.pm
    if ($xml->{maid}->{set} eq "on") {
        $config .= '    <maid>'."\n";
        if ($xml->{maid}->{number} eq "on") {
            $config .= '        <number/>'."\n";
        }
        if ($xml->{maid}->{html} eq "on") {
            $config .= '        <html/>'."\n";
        }
        if ($xml->{maid}->{simbols} eq "on") {
            $config .= '        <simbols/>'."\n";
        }
        if ($xml->{maid}->{stoplist}->{set} eq "on") {
            $config .= '        <stoplist';
            if ($xml->{maid}->{stoplist}->{dir} ne "") {
                $config .= ' dir="'.$xml->{maid}->{stoplist}->{dir}.'"';
            }
            $config .= '>'."\n";
            $count = 0;
            foreach $option (keys %{$xml->{maid}->{stoplist}->{stopfiles}}) {
                $config .= '            <stopfile>';
                $config .= $option;
                $config .= '</stopfile>'."\n";
                $count++;
            }
            if ($count == 0) {
                $config .= '            <stopfile></stopfile>'."\n";
            }
            $config .= '        </stoplist>'."\n";
        }
        if ($xml->{maid}->{stemming}->{set} eq "on") {
            $config .= '        <stemming';
            if ($xml->{maid}->{stemming}->{dir} ne "") {
                $config .= ' dir="'.$xml->{maid}->{stemming}->{dir}.'"';
            }
            $config .= '/>'."\n";
        }

        $config .= '    </maid>'."\n\n";
    }

    #NGram.pm
    if ($xml->{ngram}->{set} eq "on") {
        $config .= '    <ngram';
        if ($xml->{ngram}->{dir} ne "") {
            $config .= ' dir="'.$xml->{ngram}->{dir}.'"';
        }
        $config .= '>'."\n";
        $count = 0;
        foreach $option (keys %{$xml->{ngram}->{gram}}) {
            $config .= '        <gram n="'.$option.'"/>'."\n";
            $count++;
        }
        if ($count == 0) {
            $config .= '        <gram n=""/>'."\n";
        }
        $config .= '    </ngram>'."\n\n";
    }

    #Report.pm
    if ($xml->{report}->{set} eq "on") {
        $config .= '    <report'."\n";
        if ($xml->{report}->{ngramdir} ne "") {
            $config .= '        ngramdir="'.$xml->{report}->{ngramdir}.'"'."\n";
        }
        if ($xml->{report}->{discover} ne "") {
            $config .= '        discover="'.$xml->{report}->{discover}.'"'."\n";
        }
        if ($xml->{report}->{graphics} ne "") {
            $config .= '        graphics="'.$xml->{report}->{graphics}.'"'."\n";
        }
        if ($xml->{report}->{taxonomy} ne "") {
            $config .= '        taxonomy="'.$xml->{report}->{taxonomy}.'"'."\n";
        }
        if ($xml->{report}->{transpose} eq "on") {
            $config .= '        transpose="enabled"'."\n";
        }
        chomp($config);
        $config .= '>'."\n";

        $count = 0;

        foreach $n (keys %{$xml->{report}->{gram}}) {
            $config .= '        <gram n="'.$n.'"'."\n";
            $count++;
            foreach $option (keys %{$xml->{report}->{gram}->{$n}}) {
                if ($option eq "smooth") {
                    if ($xml->{report}->{gram}->{$n}->{$option} eq "on") {
                        $config .= '            smooth="enabled"'."\n";
                    }
                } elsif ($option eq "normalizetype") {
                    if ($xml->{report}->{gram}->{$n}->{$option} eq "on") {
                        $config .= '            normalizetype="c"'."\n";
                    } else {
                        $config .= '            normalizetype="l"'."\n";
                    }
                } else {
                    $config .= '            '.$option.'="';
                    $config .= $xml->{report}->{gram}->{$n}->{$option}.'"'."\n";
                }
            }
            chomp($config);
            $config .= '/>'."\n";
        }
        if ($count == 0) {
            $config .= '        <gram n=""/>'."\n";
        }
        $config .= '    </report>'."\n\n";
    }

    $config   .= '</pretext>';

    return $config;
}

sub writeXML {
    my $config = $_[0];
    my $filename;
    my $option = "";
    my $file = new IO::File;

    $filename = setString($filename,"Configuration File Name",0);
    if ($filename eq "") {
        $filename = "config.xml";
    }

    if (!($file->open(">$filename"))) {
        $option = "error";
    }

    if ($option eq "error") {
        print "Error: Can't Open File $filename.\n\n";
        print "Config File will be printed on screen.\n\n";
        print $config;
    } else {
        print $file $config;
        $file->close;
        print "File $filename Saved!\n";
    }
}

1;
