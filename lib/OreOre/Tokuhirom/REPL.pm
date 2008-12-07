package OreOre::Tokuhirom::REPL;
use strict;
use warnings;
use 5.00800;
our $VERSION = '0.01';
use Class::Component;
use Term::ReadLine;
use Term::ANSIColor;
__PACKAGE__->load_components(qw(
    Plaggerize
));

sub run {
    my $rl = Term::ReadLine->new('OreOre::REPL');
    while (defined (local $_ = $rl->readline('repl>'))) {
        next unless $_;
        print eval $_;
        print "\n";
        if (my $e = $@) {
            print STDERR color 'red bold';
            print STDERR $e;
            print STDERR color 'reset';
        } else {
            $rl->addhistory($_);
        }
    }
}

1;
__END__

=encoding utf8

=head1 NAME

OreOre::Tokuhirom::REPL -

=head1 SYNOPSIS

  use OreOre::Tokuhirom::REPL;

=head1 DESCRIPTION

OreOre::Tokuhirom::REPL is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
