package OreOre::REPL::Plugin::Concise;
use strict;
use warnings;
use base 'Class::Component::Plugin';
use B::Concise;

sub after_output :Hook {
    my ($self, $c, $src) = @_;

    my $code = eval "no warnings 'redefine'; sub { $src }";
    die $@ if $@;
    my $walker = B::Concise::compile('-exec', $code);
    $walker->();
}

1;
