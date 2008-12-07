package OreOre::Tokuhirom::REPL::Util;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw/commify/;

sub commify {
    local $_ = shift;
    1 while s/((?:\A|[^.0-9])[-+]?\d+)(\d{3})/$1,$2/s;
    return $_;
}

1;
