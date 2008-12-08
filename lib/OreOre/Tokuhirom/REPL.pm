package OreOre::Tokuhirom::REPL;
use strict;
use warnings;
use 5.00800;
our $VERSION = '0.01';
use Term::ReadLine;
use Term::ANSIColor;
use Data::Dumper;
use Class::Component;
use Lexical::Persistence;
use Class::Accessor::Lite;

our $PACKAGE = 'main';

Class::Accessor::Lite->mk_accessors(qw/rl/);

sub run {
    my $class = shift;
    my $c = $class->new({
        rl => Term::ReadLine->new('OreOre::REPL'),
    });
    my $counter = 1;
    while (defined (local $_ = $c->rl->readline("repl($PACKAGE)> "))) {
        next unless $_;
        eval {
            $class->run_once($c, $_);
        };
        error($@) if $@;
    }
}

sub run_once {
    my ($class, $c, $src) = @_;

    if (my ($plugin) = ($src =~ /^:load\s*(\S+)/)) {
        print "loading $plugin\n";
        $c->load_plugins($plugin);
    } else {
        $c->run_hook('before_eval');
        my $code = eval "package $PACKAGE;sub { $src; BEGIN { \$PACKAGE = __PACKAGE__ }}; "; ## no critic.
        die $@ if $@;

        my $res = $code->();
        $c->run_hook('after_eval');

        $c->run_hook('before_output');
        print Dumper($res) if $res;
        print "\n";
        $c->run_hook('after_output');

        $c->rl->addhistory($src);
    }
}

sub error {
    my $e = shift;
    print STDERR color 'red bold';
    print STDERR $e;
    print STDERR color 'reset';
}

1;
