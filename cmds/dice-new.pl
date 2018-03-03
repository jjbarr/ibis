#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(reduce);
use Math::Random::Secure qw(irand);
use Regexp::Grammars;
use re 'eval';

sub fail{
    print "I reject your reality and substitute my own!\n";
    exit 1;
}

sub repres_m{
    my (%t) = @_;
    if($t{v2}){print "("}
    my $v1 = repres_as(%{$t{v1}});
    if($t{v2}){
        print " * ";
        my $v2 = repres_as(%{$t{v2}});
        print ")";
        return $v1*$v2;
    }
    return $v1;
}

sub repres_as{
    my (%t) = @_;
    if($t{v2}){print "("}
    my $v1 = repres_v(%{$t{v1}});
    if($t{v2}){
        print " " . $t{op} . " ";
        my $v2 = repres_v(%{$t{v2}});
        print ")";
        return ($t{op} eq "+")?$v1+$v2:$v1-$v2;
    }
    return $v1;
}

sub repres_v{
    my (%t) = @_;
    if($t{n}){print $t{n}; return $t{n}}
    if($t{m}){print "(";my $e = repres_m(%{$t{m}});print ")"; return $e}
    if($t{roll}){return repres_roll(%{$t{roll}});}
}

sub repres_roll{
    my (%t) = @_;
    my @dice=map {irand($t{x})+1} (1..$t{n});
    if($t{reron}){@dice=map {($_==$t{reron})?irand($t{x}+1):$_} @dice}
    if($t{xabv}){@dice=map {$_>=$t{xabv}?($_,irand($t{x}+1)):$_} @dice}
    if($t{knum}){@dice=(reverse(sort {$a<=>$b} @dice))[0..$t{knum}-1]}
    if($t{klnum}){@dice=(sort {$a<=>$b} @dice)[0..$t{klnum}-1]}
    printf "(%s)", join(", ", @dice);
    return reduce {$a + $b} @dice;    
}

$ARGV[0] =~ /
    <nocontext:>
    (\/[A-Za-z]+\s+)?
    (r\s+<rtimes=(\d+)>\s+)?
    <m>
    (\s*<tail>)?
    <rule: m> <v1=as> (\* <v2=as>)?
    <rule: as> <v1=v> (<op=(\+|\-)> <v2=v>)?
    <rule: v> <roll>|<n=((\-)?\d+)>|\( <m> \)
    <token: roll>
    <n=(\d+)>d<x=(\d+)> 
    (r<reron=(\d+)>)? 
    (!<xabv=(\d+)>)? 
    ((k<knum=(\d+)>)|(kl<klnum=(\d+)>))?
    <rule: tail>
    ((>=<osucc=(\d+)>)|(\<=<usucc=(\d+)>))?
    (; <comment=(.*)>)?  
/x or fail();

for my $i (1..($/{rtimes} or 1)){
    my $res = repres_m(%{$/{m}});
    printf "=%d", $res;
    if($/{tail}){
        if($/{tail}{osucc}){print (($res>=$/{tail}{osucc})?"(success)":"(failure)")}
        elsif($/{tail}{usucc}){print (($res<=$/{tail}{usucc})?"(success)":"(failure)")}
    }
    print "\n";
}

if($/{tail}&&$/{tail}{comment}){printf ";%s", $/{tail}{comment}}
