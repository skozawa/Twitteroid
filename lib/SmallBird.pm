package SmallBird;
use strict;

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
    $this->{follow_list}->{$follow} = 1;
    ## followしたbirdのfollowerへの追加
    $this->{manager}->follow($this, $follow);
    
}

## follower_listへの追加
sub follower {
    my $this = shift;
    my $follower = shift;
    
    return if(!defined $follower);
    
    $this->{follower_list}->{$follower} = 1;
}

## Unfollow: follow_listからの削除
sub unfollow {
    my $this = shift;
    my $unfollow = shift;
    
    return if(!defined $unfollow);
    
    delete $this->{follow_list}->{$unfollow};
    $this->{manager}->unfollow($this, $unfollow);
}

## follower_listからの削除
sub unfollower {
    my $this = shift;
    my $unfollower = shift;
    
    return if(!defined $unfollower);
    
    delete $this->{follower_list}->{$unfollower};
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
    $this->{manager}->add_timeline($this->{name}."_list_".$name, $bird_list);
}

## listのタイムラインを取得
sub list_timeline {
    my $this = shift;
    my ($list_name) = shift;
    
    if(!defined $this->{lists}->{$list_name}) { die "Not found list"; }
    
    return $this->{manager}->get_timeline($this->{name}."_list_".$list_name)->{tweet_list};
}

## listにbirdを追加
sub add_bird_to_list {
    my $this = shift;
    my ($list_name, $bird_list) = @_;
    
    if(!defined $this->{lists}->{$list_name}) { die "Not found list"; }
    
    $this->{manager}->add_bird_to_timeline($this->{name}."_list_".$list_name, $bird_list);
}

## listからbirdを削除
sub remove_bird_from_list {
    my $this = shift;
    my ($list_name, $bird_list) = @_;
    
    if(!defined $this->{lists}->{$list_name}) { die "Not found list"; }
    
    $this->{manager}->remove_bird_from_timeline($this->{name}."_list_".$list_name, $bird_list);
}

1;
