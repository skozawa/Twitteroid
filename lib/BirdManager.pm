## BirdとTimelineの管理
package BirdManager;
use strict;
use warnings;

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
    
    ## followしたBird用のタイムラインを生成
    my $timeline_name = $this->make_timeline_name($bird->get_name, "friends");
    $this->add_timeline($timeline_name, []);
    
    return $bird;
}

## Timelineの追加
sub add_timeline {
    my $this = shift;
    my ($name, $bird_list) = @_;
    
    my $timeline = TweetTimeline->new();
    $timeline->add_bird($bird_list);
    $this->{timeline_list}->{$name} = $timeline;
}

## タイムラインの名前を生成
sub make_timeline_name {
    my $this = shift;
    my ($bird_name, $type, $list_name) = @_;
    
    my $timeline_name = $bird_name."_".$type;
    $timeline_name .= "_".$list_name if ( defined $list_name );
    
    return $timeline_name;
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
	if($timeline->exist_bird($bird_name)) {
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
    
    $bird2->add_follower($bird1);
    
    $this->add_bird_to_timeline($bird1->get_name."_friends", [$bird2]);
}

## タイムラインにbirdを追加
sub add_bird_to_timeline {
    my $this = shift;
    my ($timeline_name, $bird_list) = @_;

    my $timeline = $this->{timeline_list}->{$timeline_name};
    $timeline->add_bird($bird_list);
}


## bird1がunfollowしたとき発生
## bird2のfollower_listからbird1を削除
## bird1のタイムラインからbird2を除去
sub unfollow {
    my $this = shift;
    my ($bird1, $bird2) = @_;
    
    $bird2->remove_follower($bird1);
    
    $this->remove_bird_from_timeline($bird1->get_name."_friends", [$bird2]);
}

## タイムラインからbirdを削除
sub remove_bird_from_timeline {
    my $this = shift;
    my ($timeline_name, $bird_list) = @_;
    
    my $timeline = $this->{timeline_list}->{$timeline_name};
    $timeline->remove_bird($bird_list);
}

1;

