package Timeline;
use strict;

use base qw(Class::Accessor);
__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_accessor(qw/owner/);

sub create_timeline {
    die;
}

sub add_bird {
    die;
}

sub remove_bird {
    die;
}


1;
