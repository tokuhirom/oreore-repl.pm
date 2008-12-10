package OreOre::REPL;
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
use OreOre::REPL::Dumper::DataDumper; # default dumper
use UNIVERSAL::require;

our $PACKAGE = 'main';

Class::Accessor::Lite->mk_accessors(qw/rl lex dumper/);

sub run {
    my $class = shift;
    my $c = $class->new({
        rl => Term::ReadLine->new('OreOre::REPL'),
        lex => Lexical::Persistence->new(),
        dumper => 'OreOre::REPL::Dumper::DataDumper',
    });
    my $counter = 1;
    $class->show_banner();
    while (defined (local $_ = $c->rl->readline("repl($PACKAGE)> "))) {
        next unless $_;
        eval {
            $class->run_once($c, $_);
        };
        error($@) if $@;
    }
}

sub show_banner {
    print color 'green';
    print "$0 version $VERSION\n";
    print "type :help for display help message\n";
    print color 'reset';
    print "\n";
}

sub run_once {
    my ($class, $c, $src) = @_;

    if (my ($a) = ($src =~ /^\?\s*(.+)$/)) {
        # help
        $c->run_help($a);
    } elsif (my ($cmd, $args) = ($src =~ /^:([a-z]+)(?:\s+(\S+))?$/)) {
        # run builtin command
        my $meth = "cmd_$cmd";
        if ($c->can($meth)) {
            $c->$meth($args);
        } else {
            error("unknown command: $cmd\n");
        }
    } else {
        $c->run_hook('before_eval');
        ## no critic.
        my $compiled = join('',
            "package $PACKAGE;",
            map({ "my $_;\n" } keys %{$c->lex->get_context('_')}),
            "sub { $src }",
            ';BEGIN { $PACKAGE = __PACKAGE__ }'
        );
        my $code = eval $compiled;
        die $@ if $@;

        my @res = $c->lex->wrap($code)->();
        $c->run_hook('after_eval');

        $c->run_hook('before_output');
        print $c->dumper->dump(@res) if @res;
        print "\n";
        $c->run_hook('after_output');
    }
}

sub error {
    my $e = shift;
    print STDERR color 'red bold';
    print STDERR $e;
    print STDERR color 'reset';
}

sub cmd_load {
    my ($c, $plugin) = @_;
    print "loading $plugin\n";
    $plugin =~ s/;$//;
    $c->load_plugins($plugin);
}

sub cmd_dumper {
    my ($c, $dumper) = @_;
    print "dumper switch to $dumper\n";
    my $klass = "OreOre::REPL::Dumper::$dumper";
    $klass->use or die $@;
    $c->dumper($klass);
}

sub cmd_help {
    print <<'...';
*switch dumper module
    :dumper DataDumper
    :dumper JSON
    :dumper YAML
*loading plugins
    :load Memory
    :load Yosh
*more help
    ? Digest::MD5
...
}

my %perlfuncs = 
    map { $_ => 1 }
qw(
  abs accept alarm atan bind binmode bless break caller chdir chmod chomp chop chown chr chroot close closedir connect
  continue cos crypt dbmclose dbmopen defined delete die do dump each endgrent endhostent endnetent endprotoent endpwent
  endservent eof eval exec exists exit exp fcntl fileno flags flock fork format formline getc getgrent getgrgid getgrnam
  gethostbyaddr gethostbyname gethostent getlogin getnetbyaddr getnetbyname getnetent getpeername getpgrp getppid
  getpriority getprotobyname getprotobynumber getprotoent getpwent getpwnam getpwuid getservbyname getservbyport getservent
  getsockname getsockopt glob gmtime goto grep hex import index int ioctl join keys kill last lc lcfirst length link
  listen local localtime lock log lstat m map mkdir msgctl msgget msgrcv msgsnd my next no oct open opendir ord order
  our pack package pipe pop pos precision print printf prototype push q qq qr quotemeta qw qx rand read readdir readline
  readlink readpipe recv redo ref rename require reset return reverse rewinddir rindex rmdir s say scalar seek seekdir select
  semctl semget semop send setgrent sethostent setnetent setpgrp setpriority setprotoent setpwent setservent setsockopt shift
  shmctl shmget shmread shmwrite shutdown sin size sleep socket socketpair sort splice split sprintf sqrt srand stat state
  study sub substr symlink syscall sysopen sysread sysseek system syswrite tell telldir tie tied time times tr truncate uc
  ucfirst umask undef unlink unpack unshift untie use utime values vec vector wait waitpid wantarray warn write y
);

sub run_help {
    my ($c, $args) = @_;
    $args =~ s/^\s+//;
    $args =~ s/\s+$//;
    if ($args =~ /^[a-z]+$/ && $perlfuncs{$args}) {
        $args = "-f $args";
    }
    system "perldoc $args";
}

1;
