#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;
use OreOre::Tokuhirom::REPL;
use File::Spec;
use File::HomeDir;

my $conffile = File::Spec->catfile(File::HomeDir->my_home());

my $repl = OreOre::Tokuhirom::REPL->new({config => $conffile});
$repl->run;

