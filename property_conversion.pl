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

        # Our docstring is close to being correct, but needs to be indented one more time
        my $in_docstring = 0;
        my @processed_lines = ();
        foreach my $line (split(/\n/, $matching_text)) {
            if ($line =~ m/"""/) {
                if ($in_docstring == 0) {
                    $in_docstring = 1;
                } else {
                    $in_docstring = 0;
                }
            }
            # We indent any line that is the start/end of docstring or in a docstring
            my $new_line = $line;
            if (($line =~ m/"""/) || ($in_docstring == 1)) {
                $new_line = "    " . $line;
            }
            push(@processed_lines, $new_line);
        }
        my $new_text = join("\n", @processed_lines);

        # Finally, replace original text with our new function
        $text =~ s/$pattern/$new_text/;
        print $text;

        # Only do one file for now
        last;
    }
}
