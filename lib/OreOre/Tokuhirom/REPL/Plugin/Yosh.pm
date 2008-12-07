package OreOre::Tokuhirom::REPL::Plugin::Yosh;
use strict;
use warnings;
use base 'Class::Component::Plugin';
use Time::HiRes qw/gettimeofday tv_interval/;
my ($t1, $t2);

sub before_eval :Hook {
    my ($self, $c) = @_;
    $t1 = [gettimeofday()];
}

sub after_eval :Hook {
    $t2 = [gettimeofday()];
}

sub after_output :Hook {
    my $spent = tv_interval($t1, $t2);
    print "spent time is $spent\n";
}

1;
