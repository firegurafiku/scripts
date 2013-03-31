#!/usr/bin/env perl
# Usage:
#     CheckIncludeGuard.pl [--fix] [--test|--test-pattern] FILE ...
#
# Patterns:
#     ${uppersplit($ext)} ${upper($basename)} %lower(%3) -- parent dirs.
#     %f -- basename
#     %e -- extension
#
# %uppersplit(%basename(%0)) %1 %2 %3 %4 %f %e %r
# %upper %lower %usplit %basename() %extension() % \1
#
# --guard-pattern '%upper(%usplit(%1))_%upper(%usplit(%basename(%0)))_%upper(%extension(%0))_'
# --trailing-comment-style none | c++ | c
# trailing-comment-style:
use strict;
use warnings;
use Cwd qw(abs_path);
use String::CamelCase qw(decamelize);
use Getopt::Long;

sub decamelize1($) {
    my $_ = $_[0];
    #$_ =~ s/([^A-Z])([A-Z])/1_2/g;
    return $_;
}

our %PatternFunctions = (
    "uc"         =>sub { return uc shift; },
    "lc"         =>sub { return lc shift; },
    "ucfirst"    =>sub { return ucfirst shift; },
    "lcfirst"    =>sub { return lcfirst shift; },
    "decamelize" =>sub { return decamelize shift; }, # $a = shift; $a =~ s/([^A-Z])([A-Z])/$1_\l$2/g; return $a; },
);

sub replaceSlashes($) {
    my $_ = shift; $_ =~ s/\\/\//g; return $_;
}

sub splitFileName($) {
    return reverse split '/+', shift;
}

sub generateIdent($$) {
    our ($fileName, $pattern) = @_;
    our @paths = splitFileName($fileName);
    our %funcs = %PatternFunctions;
    #eval {
        # FIXME: This was done just for fun.
        our $val;
        $pattern =~ s/
            (?{$val=""})
            ((%(\d)(?{$val=$paths[$3]})) |
             (%(\w+)\((?1)\)(?{$val = $funcs{$5}->($val)})))/$val/gx;
    #};

    return $@ ? undef : $pattern;
}

sub checkFileGuard($$) {
    my ($fileName, $pattern) = @_;

    open(HFILE, '<', $fileName) or return undef;

    my $ifndefIdent;
    my $defineIdent;
    my $endifIdent;

    my $prevLine = <HFILE>;
    my $currLine = <HFILE>;
    for ( ; $currLine; $prevLine = $currLine, $currLine = <HFILE>) {
        $prevLine =~ /^\s*#\s*ifndef\s+(\w[\w\d]*)\s*(.*)$/ or next;
        $ifndefIdent = $1;
        #print "ifndef: $ifndefIdent\n";

        $currLine =~ /^\s*#\s*define\s+(\w[\w\d]*)\s*(.*)$/ or next;
        $defineIdent = $1;
        #print "define: $defineIdent\n";
        last;
    }

    $currLine = <HFILE>;
    for ( ; $currLine; $currLine = <HFILE>) {
        $currLine =~ /^\s*\#\s*endif\s*
            (\/\*\s*(\w[\w\d]*)\s*\*\/)|(\/\/\s*(\w[\w\d]*)\s*)$/x or next;
        $endifIdent = ($2 ? $2 : $4);
        #print "endif: $endifIdent\n";
    }

    close HFILE;

    printf "%s: %s\n", $fileName, generateIdent($fileName, $pattern);
    return $ifndefIdent && $defineIdent && $endifIdent
        && $ifndefIdent eq $defineIdent && $defineIdent eq $endifIdent
        && $ifndefIdent eq generateIdent($fileName, $pattern);
}

my $pattern;
my $result = GetOptions("pattern=s" => \$pattern);
$result or die "Usage: CheckIncludeGuards.pl [--pattern PATTERN] FILES ...";

foreach my $headerFile (@ARGV) {
    my $okay = checkFileGuard(abs_path(replaceSlashes($headerFile)), $pattern);
    #$okay or print "$headerFile: ERROR\n";
}
