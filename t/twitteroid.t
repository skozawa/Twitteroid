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

sub twitter02 : Tests {
    my $BM = BirdManager->new();
    
    my @tweets = (["Tweet1-1","Tweet1-2"],
		  ["Tweet2-1","Tweet2-2"],
		  ["Tweet3-1"],
		  ["Tweet4-1"],
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
    dies_ok {$BM->add_bird();};
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
    
    $b1->make_list("test", [$b2, $b3]);
    my $list_tl = $b1->list_timeline("test");
    is $list_tl->[0]->get_message, $tweets[1][1];
    
    my $b4 = $BM->add_bird({ name => 'user4' });
    
    $b1->add_bird_to_list("test", [$b4]);
    
    $b4->tweet($tweets[3][0]);
    is $list_tl->[0]->get_message, $tweets[3][0];

    $b1->remove_bird_from_list("test", [$b3,$b4]);
    is $list_tl->[0]->get_message, $tweets[1][1];
}


sub twitter03 : Tests {
    my $BM = BirdManager->new();
    
    my @tweets = (["Tweet0-1","Tweet0-2"],
		  ["Tweet1-1","Tweet1-2","Teest1-3"],
		  ["Tweet2-1"],
		  ["Tweet3-1"],
		  ["Tweet4-1","Tweet4-2"],
		  ["Tweet5-1","Tweet5-2","Tweet5-3"],
		  );
    my @birds;
    $birds[$_] = $BM->add_bird({ name => 'user'.$_} ) for ( 0 .. 5 );
    
    $birds[$_]->tweet($tweets[$_][0]) for ( 0 .. 5 );
        
    $birds[0]->follow($birds[$_]) for ( 1 .. 3 );
    
    my @tls;
    $tls[$_] = $birds[$_]->friends_timeline for ( 0 .. 5 );
    
    is $tls[0]->[0]->get_message, $tweets[3][0];
    
    $birds[0]->make_list("list", [@birds[3..5]]);
    my $list_tl0 = $birds[0]->list_timeline("list");
    is $list_tl0->[0]->get_message, $tweets[5][0];
    
    dies_ok {$birds[0]->make_list("list", [@birds[1..2]]);};
    
    dies_ok {$birds[1]->make_list("", [@birds[0,2..5]]);};
    $birds[1]->make_list("list", [@birds[0,2..5]]);
    
    $birds[$_]->tweet($tweets[$_][1]) for ( 0..1, 4..5 );
    
    dies_ok {$birds[1]->list_timeline("list2");};
    my $list_tl1 = $birds[1]->list_timeline("list");
    is $list_tl1->[0]->get_message, $tweets[5][1];
    is $list_tl1->[2]->get_message, $tweets[0][1];
    is $list_tl0->[1]->get_message, $tweets[4][1];
    
    $birds[1]->tweet($tweets[1][2]);
    
    $birds[0]->add_bird_to_list("list", [$birds[1], "test"]);
    is $list_tl0->[0]->get_message, $tweets[1][2];
    
    $birds[0]->remove_bird_from_list("list", [$birds[1],"test",$birds[0],$birds[1]]);
    is $list_tl0->[1]->get_message, $tweets[4][1];
}

__PACKAGE__->runtests;


1;
