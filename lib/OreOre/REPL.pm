package OreOre::REPL;
use strict;
use warnings;
use base qw/Class::Accessor::Fast/;
use 5.00800;
our $VERSION = '0.01';
use Term::ReadLine;
use Term::ANSIColor;
use Data::Dumper;
use Lexical::Persistence;
use OreOre::REPL::Dumper::DataDumper; # default dumper
use UNIVERSAL::require;
use OreOre::REPL::Command;

our $PACKAGE = 'main';

__PACKAGE__->mk_accessors(qw/rl lex dumper log/);

sub run {
    my $class = shift;
    my $c = $class->new({
        rl => Term::ReadLine->new('OreOre::REPL'),
        lex => Lexical::Persistence->new(),
        dumper => 'OreOre::REPL::Dumper::DataDumper',
        log => [],
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
        if (my $cv = OreOre::REPL::Command->can($meth)) {
            $cv->($c, $args);
        } else {
            error("unknown command: $cmd\n");
        }
    } else {
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

        my $dumped = '';
        if (@res) {
            $dumped = $c->dumper->dump(@res);
            print $dumped;
        }
        print "\n";

        push @{ $c->{log} }, { src => $src, 'dumped' => $dumped, package => $PACKAGE};
    }
}

sub error {
    my $e = shift;
    print STDERR color 'red bold';
    print STDERR $e;
    print STDERR color 'reset';
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
