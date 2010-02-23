package OreOre::REPL::Command;
use strict;
use warnings;
use List::Util qw/min/;

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
*more help
    ? Digest::MD5
*reload modules
    :reload
...
}

sub cmd_reload {
    require Module::Reload;
    Module::Reload->check;
    print "module reloaded\n";
}

1;
