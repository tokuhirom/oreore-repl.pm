package OreOre::Tokuhirom::REPL;
use strict;
use warnings;
use 5.00800;
our $VERSION = '0.01';
use Term::ReadLine;
use Term::ANSIColor;
use Data::Dumper;
use Class::Component;

our $PACKAGE = 'main';

sub run {
    my $class = shift;
    my $c = $class->new;
    my $rl = Term::ReadLine->new('OreOre::REPL');
    my $counter = 1;
    while (defined (local $_ = $rl->readline("repl($PACKAGE)> "))) {
        next unless $_;

        if (my ($plugin) = ($_ =~ /^:load\s*(\S+)/)) {
            print "loading $plugin\n";
            use UNIVERSAL::which;
            $c->load_plugins($plugin);
            next;
        }

        eval {
            my $code = eval "package $PACKAGE;sub { $_; BEGIN { \$PACKAGE = __PACKAGE__ }}; ";
            die $@ if $@;

            $c->run_hook('before');
            my $res = $code->();
            $c->run_hook('after');
            print Dumper($res) if $res;
            print "\n";

            $rl->addhistory($_);
        };
        if (my $e = $@) {
            print STDERR color 'red bold';
            print STDERR $e;
            print STDERR color 'reset';
        }
    }
}

1;
