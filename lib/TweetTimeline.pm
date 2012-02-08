package TweetTimeline;
use strict;

use base qw(Timeline);

sub new {
    my $class = shift;
    my $this = {
	tweet_list => [],
	bird_list => {},
    };
    return bless $this, $class;
}

## followしているbirdのTweet全てをソート
sub initialize {
    my $this = shift;
    
    my @all_tweet = ();
    foreach my $name (keys %{$this->{bird_list}}) {
	push @all_tweet, @{$this->{bird_list}->{$name}->{tweet_list}};
    }
    @{$this->{tweet_list}} = sort {$b->{time} <=> $a->{time}}  @all_tweet;
}

## タイムラインにTweetを追加
sub add_tweet {
    my $this = shift;
    my $tweet = shift;
    
    unshift @{$this->{tweet_list}}, $tweet;
}

## TimelineにBirdを追加
## タイムラインを初期化（再ソート）
sub add_bird {
    my $this = shift;
    my ($name, $bird) = @_;
    
    $this->{bird_list}->{$name} = $bird;
    $this->initialize();
}

## TimelineからBirdを削除
sub remove_bird {
    my $this = shift;
    my ($name) = @_;
    
    delete $this->{bird_list}->{$name};
    $this->initialize();
}


1;

