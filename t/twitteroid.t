package test::BirdManager;

use strict;
use warnings;

use base qw(Test::Class);
use Test::More;
use Test::Exception;

use BirdManager;

BEGIN {
    use_ok 'BirdManager';
    use_ok 'Manager';
    use_ok 'Timeline';
    use_ok 'TweetTimeline';
    use_ok 'Bird';
    use_ok 'SmallBird';
    use_ok 'Tweet';
}

sub init : Test {
    new_ok 'BirdManager';
}

sub twitter01 : Tests {
    my $BM = BirdManager->new();
    
    my $b1 = $BM->add_bird({ name => 'user1' });
    my $b2 = $BM->add_bird({ name => 'user2' });
    my $b3 = $BM->add_bird({ name => 'user3' });
    
    $b1->follow($b2);
    $b1->follow($b3);
    
    $b3->follow($b1);
    
    my @tweets = ("今日は寒いですね", "散歩中", "名古屋なう");
    
    $b1->tweet($tweets[0]);
    $b2->tweet($tweets[1]);
    $b3->tweet($tweets[2]);
    
    is_deeply $b1->{follow_list}, {$b2=>1,$b3=>1};
    is_deeply $b1->{follower_list}, {$b3=>1};
    
    my $b1_timeline = $b1->friends_timeline;
    is $b1_timeline->[0]->get_message, $tweets[2];
    is $b1_timeline->[1]->get_message, $tweets[1];
    
    my $b3_timeline = $b3->friends_timeline;
    is $b3_timeline->[0]->get_message, $tweets[0];
}

sub twitter02 : Test {
    my $BM = BirdManager->new();
    
    my @tweets = (["Tweet1-1","Tweet1-2"],
		  ["Tweet2-1","Tweet2-2"],
		  ["Tweet3-1"],
		  );
    
    my $b1 = $BM->add_bird({ name => 'user1' });
    my $b2 = $BM->add_bird({ name => 'user2' });
    
    $b1->tweet($tweets[0][0]);
    $b1->tweet($tweets[0][1]);
    
    $b2->follow($b1);
    
    $b2->tweet($tweets[1][0]);
    
    $b1->follow($b2);
    
    my $b1_tl = $b1->friends_timeline;
    my $b2_tl = $b2->friends_timeline;
    
    is $b1_tl->[0]->get_message, $tweets[1][0];
    is $b2_tl->[0]->get_message, $tweets[0][1];
    
    my $b3 = $BM->add_bird({ name => 'user3' });
    dies_ok {$BM->add_bird();}
    $b3->tweet($tweets[2][0]);
    
    $b1->follow($b3);
    is $b1_tl->[0]->get_message, $tweets[2][0];
    
    $b2->tweet($tweets[1][1]);
    is $b1_tl->[0]->get_message, $tweets[1][1];
    
    my $b3_tl = $b3->friends_timeline;
    $b3->follow($b2);
    is $b3_tl->[0]->get_message, $tweets[1][1];
    
    $b1->unfollow($b3);
    is $b1_tl->[0]->get_message, $tweets[1][1];
    is $b1_tl->[1]->get_message, $tweets[1][0];
}


__PACKAGE__->runtests;


1;
