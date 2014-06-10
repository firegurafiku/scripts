#!/usr/bin/env perl
# Parses vcard files and prints all contacts alongside with their phone
# numbers. This may be useful, for example, for travellers not to loose
# access to their phone book in case their phone's battery got low.
# Tested on contacts exported from Nokia N900 to vcard ver. 3 format.
# ---
# Copyright (c) Pavel Kretov, 2014.
# Provided under the terms of WTFPL of any version.
use strict;
use warnings;
use open ':std', ':encoding(UTF-8)';
use Getopt::Long;
use Text::vCard::Addressbook;

my $nameWidth = 0;
my $phoneWidth = 0;
my $success = GetOptions(
    "name-width=i"  => \$nameWidth,
    "phone-width=i" => \$phoneWidth);

$success or die
    "Usage: print-vcards.pl [--name-width=0] [--phone-width=0] FILE ...";

foreach my $file (@ARGV) {
    my $book = Text::vCard::Addressbook->new({'source_file'=> $file,});
    foreach my $vcard ($book->vcards()) {
        my $fullname = $vcard->fullname();
        my $nodes = $vcard->get({'node_type'=>'phones',});
        $fullname && $nodes or next;

        printf "%*s: %*s\n",
            $nameWidth,
            $fullname,
            $phoneWidth,
            join ", ", map { $_->value() } @{$nodes};
    }
}

