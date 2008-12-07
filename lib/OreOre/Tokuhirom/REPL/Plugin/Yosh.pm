package OreOre::Tokuhirom::REPL::Plugin::Yosh;
use strict;
use warnings;
use base 'Class::Component::Plugin';
use Time::HiRes qw/gettimeofday tv_interval/;
my $t;

sub before :Hook {
    my ($self, $c) = @_;
    $t = [gettimeofday()];
}

sub after :Hook {
     my $spent = tv_interval($t, [gettimeofday]);
     print "spent time is $spent\n";
}

1;
