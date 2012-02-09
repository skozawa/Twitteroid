package SmallBird;
use strict;
use warnings;

use base qw(Bird);
use Tweet;
use Time::HiRes;

sub new {
    my $class = shift;
    my ($manager, $attrs) = @_;
    my $this = {
	manager => $manager,
	follow_list => {},
	follower_list => {},
	tweet_list => [],
	lists => {},
	%$attrs,
    };
    
    return bless $this, $class;
}

## Tweet
sub tweet {
    my $this = shift;
    my $message = shift;
    my $tweet_time = Time::HiRes::time;
    my $tweet = Tweet->new({message=>$message, time=>$tweet_time});
    unshift @{$this->{tweet_list}}, $tweet;
    
    $this->{manager}->add_tweet($this->{name}, $tweet);
}

## Follow: follow_listへの追加
sub follow {
    my $this = shift;
    my $follow = shift;
    
    return if(!defined $follow);
    
    ## follow listに追加
    $this->{follow_list}->{$follow->get_name} = $follow;
    ## followしたbirdのfollowerへの追加
    $this->{manager}->follow($this, $follow);
    
}

## follower_listへの追加
sub add_follower {
    my $this = shift;
    my $follower = shift;
    
    return if(!defined $follower);
    
    $this->{follower_list}->{$follower->get_name} = $follower;
}

## Unfollow: follow_listからの削除
sub unfollow {
    my $this = shift;
    my $unfollow = shift;
    
    return if(!defined $unfollow);
    
    delete $this->{follow_list}->{$unfollow->get_name};
    $this->{manager}->unfollow($this, $unfollow);
}

## follower_listからの削除
sub remove_follower {
    my $this = shift;
    my $unfollower = shift;
    
    return if(!defined $unfollower);
    
    delete $this->{follower_list}->{$unfollower->get_name};
}

## followしているbirdのタイムラインを取得
sub friends_timeline {
    my $this = shift;
    
    return $this->{manager}->get_timeline($this->{name}."_friends")->{tweet_list};
}

## listの生成
sub make_list {
    my $this = shift;
    my ($name, $bird_list) = @_;
    
    if(!defined $name || $name eq "") { die "Input list name"; }
    elsif(defined $this->{lists}->{$name}) { die "already exist"; }
    
    $this->{lists}->{$name} = 1;
    my $timeline_name = $this->{manager}->make_timeline_name($this->{name}, "list", $name);
    $this->{manager}->add_timeline($timeline_name, $bird_list);
}

## listのタイムラインを取得
sub list_timeline {
    my $this = shift;
    my ($list_name) = shift;
    
    if (!defined $this->{lists}->{$list_name}) { die "Not found list"; }
    
    my $timeline_name = $this->{manager}->make_timeline_name($this->{name}, "list", $list_name);
    return $this->{manager}->get_timeline($timeline_name)->{tweet_list};
}

## listにbirdを追加
sub add_bird_to_list {
    my $this = shift;
    my ($list_name, $bird_list) = @_;
    
    if (!defined $this->{lists}->{$list_name}) { die "Not found list"; }
    
    my $timeline_name = $this->{manager}->make_timeline_name($this->{name}, "list", $list_name);
    $this->{manager}->add_bird_to_timeline($timeline_name, $bird_list);
}

## listからbirdを削除
sub remove_bird_from_list {
    my $this = shift;
    my ($list_name, $bird_list) = @_;
    
    if (!defined $this->{lists}->{$list_name}) { die "Not found list"; }
    
    my $timeline_name = $this->{manager}->make_timeline_name($this->{name}, "list", $list_name);
    $this->{manager}->remove_bird_from_timeline($timeline_name, $bird_list);
}

1;
