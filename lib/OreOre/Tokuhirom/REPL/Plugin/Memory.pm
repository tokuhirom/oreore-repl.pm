package OreOre::Tokuhirom::REPL::Plugin::Memory;
use strict;
use warnings;
use base 'Class::Component::Plugin';
use GTop;
my $gtop = GTop->new();

sub before_eval :Hook {
    my ($self, $c) = @_;
    $self->{s1} = $gtop->proc_mem($$)->size();
}

sub after_eval :Hook {
    my ($self, $c) = @_;
    $self->{s2} = $gtop->proc_mem($$)->size();
}

sub after_output :Hook {
    my ($self, $c) = @_;
    print "used memory: @{[ $self->{s2} - $self->{s1} ]}\n";
}

1;
