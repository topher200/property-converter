#!/usr/bin/perl
use autodie;
use strict;
use warnings;

use File::Find;
use File::Slurp;
use Path::Class;

use open qw< :encoding(UTF-8) >;

# find all python files
my $dir = dir("/Users", "t.brown", "dev", "wordstream");
my @files;
find(
    sub { push @files, $File::Find::name unless -d; },
    $dir
);

for my $filename (@files) {
    if ($filename !~ /\.py$/) {
            next;
        }
        print $filename . "\n";

        my $text = read_file($filename);
        # print $text;

        if ($text =~ s/
(.*)def\s(\w+)\(\):.*\n  # outer def
    \s*def\sfget\(self\):\n  # def fget(self):
    \s*(return.*)  # entirety of fget function, until the return line
    [\S\s]*?
    \s*$2\s=\s(\w+)\(.*  # property declaration line
    [\S\s]*?
    ====\n  # Start of Getter
    ([\S\s]*?)\n  # All of the Getter docstring
    \s*\n
    \s*Setter  # Start of Setter line
    [\S\s]*?
    \s*"""  # End of docstring
/$1\@property
$1def $2(self):
$1"""
$5
$1"""
$1    $3
                      /x) {
        my $indent = $1;
        my $function_name = $2;
        my $function_body = $3;
        my $property_name = $4;
        my $getter_docstring = $5;
        print $indent, "\n";
        print $function_name, "\n";
        print $function_body, "\n";
        print $property_name, "\n";
        print $text;
        last;
    }
}
