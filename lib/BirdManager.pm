## BirdとTimelineの管理
package BirdManager;
use strict;

use base qw(Manager);
use SmallBird;
use TweetTimeline;

sub new {
    my $class = shift;
    my $this = {
	bird_list => {},
	timeline_list => {},
    };
    
    return bless $this, $class;
}

## Birdの追加
sub add_bird {
    my $this = shift;
    my $bird = SmallBird->new($this, @_);
    $this->{bird_list}->{$bird->get_name} = $bird;
        
    return $bird;
}

## Timelineの追加
sub add_timeline {
    my $this = shift;
    my ($name, $bird_list) = @_;
    
    my $timeline = TweetTimeline->new({bird_list=>$bird_list});
    $this->{timeline_list}->{$name} = $timeline;
    $timeline->initialize();
}

## Timelineの取得
sub get_timeline {
    my $this = shift;
    my $name = shift;
    
    return $this->{timeline_list}->{$name};
}

## BirdがTweetしたとき発生
## Birdが含まれるTimelineにTweetを追加
sub add_tweet {
    my $this = shift;
    my ($bird_name, $tweet) = @_;
    
    foreach my $name (keys %{$this->{timeline_list}}) {
	my $timeline = $this->{timeline_list}->{$name};
	if(defined $timeline->{bird_list}->{$bird_name}) {
	    $timeline->add_tweet($tweet);
	}
    }
}

## Bird1がfollowしたとき発生
## followされたBird2のfollowerへ追加
## Bird1のタイムラインにBird2を追加
sub follow {
    my $this = shift;
    my ($bird1, $bird2) = @_;
    
    $bird2->follower($bird1);
    
    my $b1_friends_timeline = $this->{timeline_list}->{$bird1->get_name."_friends"};
    $b1_friends_timeline->add_bird($bird2->get_name, $bird2);
}



1;

