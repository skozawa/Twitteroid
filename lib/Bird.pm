package Bird;
use strict;
use warnings;

use base qw(Class::Accessor);
__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_accessors(qw/name/);

sub tweet {
    die;
}

sub follow {
    die;
}

sub unfollow {
    die;
}

sub follower {
    die;
}

sub unfollower {
    die;
}

1;
