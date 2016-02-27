#!/usr/bin/perl

package main;

#use lib '/opt/pretext';

use strict;
use warnings;

use Message;
use ReadConfig;
use Maid;
use NGram;
use Report;

#--------------------------------------------------
# Inicio - Benchmark 
#-------------------------------------------------- 
my $starttime = time;

#--------------------------------------------------
# Leitura de configuracoes
#-------------------------------------------------- 
my $config = new ReadConfig();
my $msg    = new Message($config);

#--------------------------------------------------
# Opcoes do pretext
# 1 = 0b0000001 = Maid
# 2 = 0b0000010 = NGram
# 4 = 0b0000100 = Report
# 8 = 0b0001000 = ?
# 16= 0b0010000 = ?
# 36= 0b0100000 = ?
# 64= 0b1000000 = ?
#-------------------------------------------------- 
my $options = $config->getPretextOptions();
$config->printPretext();

if ($options & 0b0000001) {
    $config->printMaid();
    new Maid($config);
}

if ($options & 0b0000010) {
    $config->printNGram();
    my $gram = new NGram($config);
    $gram->createGram();
}

if ($options & 0b0000100) {
    $config->printReport();
    new Report($config);
}

#--------------------------------------------------
# Fim - Benchmark
#-------------------------------------------------- 
my $endtime = time;
my $totaltime = $endtime - $starttime;

$msg->quickPrint("\n#-------------------#\n".
                 "Total Time: $totaltime\n".
                 "#-------------------#\n\n");

1;
