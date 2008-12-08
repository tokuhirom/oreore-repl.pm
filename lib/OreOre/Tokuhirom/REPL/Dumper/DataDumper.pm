package OreOre::Tokuhirom::REPL::Dumper::DataDumper;
use strict;
use warnings;
use Data::Dumper;

sub dump {
    my ($class, @stuff) = @_;
    Dumper(@stuff);
}

1;
