package OreOre::REPL::Plugin::Memory;
use strict;
use warnings;
use base 'Class::Component::Plugin';
use OreOre::REPL::Util;
use GTop;
my ($s1, $s2);
my $gtop = GTop->new();

sub before_eval :Hook {
    my ($self, $c) = @_;
    $s1 = $gtop->proc_mem($$)->size();
}

sub after_eval :Hook {
    my ($self, $c) = @_;
    $s2 = $gtop->proc_mem($$)->size();
}

sub after_output :Hook {
    my ($self, $c) = @_;
    print "used memory: @{[ commify($s2 - $s1) ]}, total: @{[ commify($s2) ]}\n";
}

1;
