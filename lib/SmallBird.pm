package SmallBird;
use strict;

use base qw(Bird);
use Tweet;

sub new {
    my $class = shift;
    my ($manager, $attrs) = @_;
    my $this = {
	manager => $manager,
	follow_list => [],
	follower_list => [],
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
    
    ## follow listに追加
    push @{$this->{follow_list}}, $follow;
    ## followしたbirdのfollowerへの追加
    $this->{manager}->follow($this, $follow);
    
}

sub follower {
    my $this = shift;
    my $follower = shift;
    
    push @{$this->{follower_list}}, $follower;
}

sub friends_timeline {
    my $this = shift;
    
    return $this->{manager}->get_timeline($this->{name}."_friends")->{tweet_list};
}

1;