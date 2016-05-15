#!/usr/bin/perl
use autodie;
use strict;
use warnings;

use File::Find;
use File::Slurp;
use Path::Class;

use open qw< :encoding(UTF-8) >;

# find all python files
my $dir = dir("/Users", "t.brown", "dev", "wordstream", "client", "manager", "src", "m1",
              "handlers", "api", "wordstream");
my @files;
find(
    sub { push @files, $File::Find::name unless -d; },
    $dir
);

# Prepare pattern and substitution
my $pattern_string = read_file("fget_pattern.txt");
my $substitution_string = read_file("fget_substitution.txt");
my $pattern = qr/$pattern_string/x;
# Must enclose substitution in double quotes to be evaluated
my $substitution = '"' . $substitution_string . '"';

for my $filename (@files) {
    if ($filename !~ /\.py$/) {
        next;
    }
    print $filename . "\n";

    my $text = read_file($filename);

    if ($text =~ s/$pattern/$substitution/ee) {
        my $indent = $1;
        my $function_name = $2;
        my $function_body = $3;
        my $property_name = $4;
        my $getter_docstring = $5;
        print $indent, "\n";
        print $function_name, "\n";
        print $function_body, "\n";
        print $property_name, "\n";
        print $getter_docstring, "\n";
        print $text;
        last;
    }
}
