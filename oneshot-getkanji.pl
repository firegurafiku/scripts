#!/usr/bin/perl
# Simple script to used once to batch download kanji images from yosida.com
# Japanese school website. Input file is a list of kanji in UTF-8 with one
# (exactly) kanji on line. Images are downloaded to KANJILIST_animations/
# and KANJILIST_statics/ directories.
#
# Usage: $ perl oneshot-getkanji.pl KANJILIST
#
# Written by Firegurafiku, 2009.
# Licensed uner the terms of WTFPL of any version.
use warnings;
use utf8;


if ($#ARGV < 0) { die "getkanji.pl kanjilist.txt"; }

open KANJILIST, "<:encoding(UTF-8)", $ARGV[0] or die "couldnt open file";

my $baseurl    = "http://www.yosida.com/images/kanji";
my $animations = $ARGV[0]."_animations";
my $statics    = $ARGV[0]."_statics";

mkdir $animations;
mkdir $statics;

while (my $kanji = <KANJILIST>)
{
	chomp $kanji;
	my $k = $kanji;
	my $code = sprintf "%04X", ord($k);
	
	print "wgetting kanji $k with $code ... \n";
	system "wget '$baseurl/$code.gif' -P '$animations'";
	system "wget '$baseurl/${code}_still.gif' -P '$statics'"
}

