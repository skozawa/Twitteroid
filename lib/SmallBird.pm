package SmallBird;
use strict;

use base qw(Bird);
use Tweet;

sub new {
    my $class = shift;
    my ($manager, $attrs) = @_;
    my $this = {
	manager => $manager,
	follow_list => {},
	follower_list => {},
	tweet_list => [],
	%$attrs,
    };
    ## followしたBird用のタイムラインを生成
    $this->{manager}->add_timeline($this->{name}."_friends", {});
    return bless $this, $class;
}


sub tweet {
    my $this = shift;
    my $message = shift;
    my $tweet = Tweet->new({message=>$message, time=>time()});
    unshift @{$this->{tweet_list}}, $tweet;
    
    $this->{manager}->add_tweet($this->{name}, $tweet);
}


sub follow {
    my $this = shift;
    my $follow = shift;
    
    return if(!defined $follow);
    
    ## follow listに追加
    $this->{follow_list}->{$follow} = 1;
    ## followしたbirdのfollowerへの追加
    $this->{manager}->follow($this, $follow);
    
}

sub follower {
    my $this = shift;
    my $follower = shift;
    
    return if(!defined $follower);
    
    $this->{follower_list}->{$follower} = 1;
}

sub unfollow {
    my $this = shift;
    my $unfollow = shift;
    
    return if(!defined $unfollow);
    
    delete $this->{follow_list}->{$unfollow};
    $this->{manager}->unfollow($this, $unfollow);
}

sub unfollower {
    my $this = shift;
    my $unfollower = shift;
    
    return if(!defined $unfollower);
    
    delete $this->{follower_list}->{$unfollower};
}

sub friends_timeline {
    my $this = shift;
    
    return $this->{manager}->get_timeline($this->{name}."_friends")->{tweet_list};
}

1;
