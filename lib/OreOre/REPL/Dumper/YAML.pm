package OreOre::REPL::Dumper::YAML;
use strict;
use warnings;
use YAML ();

sub dump {
    my ($class, @stuff) = @_;
    YAML::Dump(@stuff);
}

1;
