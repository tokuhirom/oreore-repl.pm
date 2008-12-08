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

Class::Accessor::Lite->mk_accessors(qw/rl lex/);

sub run {
    my $class = shift;
    my $c = $class->new({
        rl => Term::ReadLine->new('OreOre::REPL'),
        lex => Lexical::Persistence->new(),
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
        $plugin =~ s/;$//;
        $c->load_plugins($plugin);
    } else {
        $c->run_hook('before_eval');
        ## no critic.
        $src = join('',
            "package $PACKAGE;",
            map({ "my $_;\n" } keys %{$c->lex->get_context('_')}),
            "sub { $src }",
            ';BEGIN { $PACKAGE = __PACKAGE__ }'
        );
        my $code = eval $src;
        die $@ if $@;

        my $res = $c->lex->wrap($code)->();
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
