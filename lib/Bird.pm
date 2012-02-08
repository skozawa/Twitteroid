package Bird;
use strict;

use base qw(Classs::Accessor);
__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_accessor(qw/name/);

sub tweet {
    die;
}

sub follow {
    die;
}


1;
