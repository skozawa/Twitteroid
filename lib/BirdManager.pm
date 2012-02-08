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
    my ($attrs) = @_;
    
    if(!defined $attrs || !defined $attrs->{name}){ die "Not define bird name";}
    
    my $bird = SmallBird->new($this, $attrs);
    
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

## bird1がfollowしたとき発生
## followされたbird2のfollowerへ追加
## bird1のタイムラインにbird2を追加
sub follow {
    my $this = shift;
    my ($bird1, $bird2) = @_;
    
    $bird2->follower($bird1);
    
    my $b1_friends_timeline = $this->{timeline_list}->{$bird1->get_name."_friends"};
    $b1_friends_timeline->add_bird($bird2->get_name, $bird2);
}

## bird1がunfollowしたとき発生
## bird2のfollower_listからbird1を削除
## bird1のタイムラインからbird2を除去
sub unfollow {
    my $this = shift;
    my ($bird1, $bird2) = @_;
    
    $bird2->unfollower($bird1);
    
    my $b1_friends_timeline = $this->{timeline_list}->{$bird1->get_name."_friends"};
    $b1_friends_timeline->remove_bird($bird2->get_name, $bird2);
}


1;

