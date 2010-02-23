#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin, 'lib');
use OreOre::REPL;

OreOre::REPL->run();

