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
    print "file: " . $filename . "\n";

    my $text = read_file($filename);

    if ($text =~ m/($pattern)/) {
        my $matching_text = $1;
        print "matching text: $matching_text\n";
        print "INDENT: '$+{INDENT}'\n";
        print "PROPERTY: '$+{PROPERTY}'\n";
        print "FUNC_NAME: '$+{FUNC_NAME}'\n";
        print "FGET_FUNC: '$+{FGET_FUNC}'\n";
        print "GETTER_DOCSTRING: '\n$+{GETTER_DOCSTRING}'\n";
        $matching_text =~ s/$pattern/$substitution/ee;
        print "replaced text, pre docstring cleanup: $matching_text\n";

        # Our docstring is close to being correct, but needs to be indented one more time
        my $in_docstring = 0;
        my @processed_lines = ();
        foreach my $line (split(/\n/, $matching_text)) {
            my $new_line = $line;
            if ($line =~ m/"""/) {
                if ($in_docstring == 0) {
                    $in_docstring = 1;
                } else {
                    $in_docstring = 0;
                }
            } else {
                # We indent any line that is in a docstring
                if ($in_docstring == 1) {
                    $new_line = "    " . $line;
                }
            }
            push(@processed_lines, $new_line);
        }
        my $new_text = join("\n", @processed_lines);

        # Finally, replace original text with our new function
        $text =~ s/$pattern/$new_text/;
        print "new file: \n$text\n";

        # Only do one file for now
        last;
    }
}
