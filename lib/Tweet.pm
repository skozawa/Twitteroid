package Tweet;
use strict;

use base qw(Class::Accessor);
__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_accessors(qw/message time at/);

sub set_at {
    my $this = shift;
    $this->{at} = [@_];
}

sub get_at {
    my $this = shift;
    return @{$this->{at}};
}


1;
