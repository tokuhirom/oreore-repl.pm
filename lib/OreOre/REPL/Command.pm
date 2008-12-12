package OreOre::REPL::Command;
use strict;
use warnings;
use List::Util qw/min/;

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

sub cmd_nopaste {
    my ($c, $num) = @_;
    $num ||= 1;

    my $log_render = sub {
        my $row = shift;
        "$row->{package}> $row->{src}\n$row->{dumped}";
    };

    my $log = do {
        my @logs = reverse @{ $c->log };
        @logs = @logs[0..min($num-1, scalar(@logs))];
        @logs = reverse @logs;
        @logs = grep { defined $_ } @logs;
        join "\n", map { $log_render->($_) } @logs;
    };

    require App::Nopaste;
    my $url = App::Nopaste::nopaste($log);
    if ($url) {
        print "$url\n";
    } else {
        print "cannot send\n";
    }
}

sub cmd_reload {
    require Module::Reload;
    Module::Reload->check;
    print "module reloaded\n";
}

1;
