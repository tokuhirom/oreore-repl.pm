package OreOre::Tokuhirom::REPL::Dumper::JSON;
use strict;
use warnings;
use JSON ();
my $dumper = JSON->new->pretty(1)->allow_nonref(1)->allow_blessed(1);

sub dump {
    my ($class, @stuff) = @_;
    $dumper->encode(@stuff);
}

1;
