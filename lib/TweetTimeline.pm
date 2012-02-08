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

## bird_listにbirdが存在するかを確認
sub exist_bird {
    my $this = shift;
    my $bird_name = shift;
    
    if(defined $this->{bird_list}->{$bird_name}) {
	return 1;
    } else {
	return 0;
    }
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
    my ($birds) = @_;
    
    foreach my $bird (@$birds) {
	next if(ref($bird) ne "SmallBird" || defined $this->{bird_list}->{$bird->get_name});
	$this->{bird_list}->{$bird->get_name} = $bird;
    }
    $this->initialize();
}

## TimelineからBirdを削除
sub remove_bird {
    my $this = shift;
    my ($birds) = @_;
    
    foreach my $bird (@$birds) {
	next if(ref($bird) ne "SmallBird" || !defined $this->{bird_list}->{$bird->get_name});
	delete $this->{bird_list}->{$bird->get_name};
    }
    $this->initialize();
}


1;

