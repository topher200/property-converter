#!/usr/bin/perl
use autodie;
use strict;
use warnings;

use File::Find;
use File::Slurp;
use Path::Class;

use open qw< :encoding(UTF-8) >;

$| = 1;  # Autoflush STDOUT

# find all python files
my $dir = dir("/Users", "t.brown", "dev", "wordstream");
my @files;
find(
    sub { push @files, $File::Find::name unless -d; },
    $dir
);

# Modify $work_on_string to change what we're working on
my $work_on_string = "fget";

# Set up filenames to read from
my $pattern_filename = "fget_pattern.txt";
$pattern_filename =~ s/fget/$work_on_string/;
my $substitution_filename = "fget_substitution.txt";
$substitution_filename =~ s/fget/$work_on_string/;

# Prepare pattern and substitution
my $pattern_string = read_file($pattern_filename);
my $substitution_string = read_file($substitution_filename);
my $pattern = qr/$pattern_string/x;
# Must enclose substitution in double quotes to be evaluated
my $substitution = '"' . $substitution_string . '"';

my $total_matches = 0;
my $total_replacements = 0;

for my $filename (@files) {
    if ($filename !~ /\.py$/) {
        next;
    }
    print "file: " . $filename . "\n";

    my $entire_file_text = read_file($filename);

    my $num_matches = () = $entire_file_text =~ m/def\sfset/g;
    $total_matches += $num_matches;

    while ($entire_file_text =~ m/($pattern)/g) {
        $total_replacements += 1;
        my $matching_text = $1;
        print "matching text: \n$matching_text\n";
        # print "INDENT: '$+{INDENT}'\n";
        # print "PROPERTY: '$+{PROPERTY}'\n";
        # print "FUNC_NAME: '$+{FUNC_NAME}'\n";
        print "FGET_FUNC: '\n$+{FGET_FUNC}'\n";
        print "GETTER_DOCSTRING: '\n$+{GETTER_DOCSTRING}'\n";

        die if ($+{FGET_FUNC} =~ m/def\s\w+\(/);
        die if ($+{FGET_FUNC} =~ m/locals/);
        die if ($+{GETTER_DOCSTRING} =~ m/\"\"\"/);
        die if ($+{GETTER_DOCSTRING} =~ m/def\s\w+\(/);

        # Strip one indentation level off of the function body
        my @processed_lines = ();
        foreach my $line (split(/\n/, $+{FGET_FUNC})) {
            $line =~ s/\h{4}//;
            push(@processed_lines, $line);
        }
        my $function_body = join("\n", @processed_lines);
        # print "function_body: '\n$function_body'\n";

        # Our docstring is close to being correct, but needs to be indented one
        # more time. We also remove the "Getter" and "====" lines.
        @processed_lines = ();
        foreach my $line (split(/\n/, $+{GETTER_DOCSTRING})) {
            # Remove Getter and '=====' lines
            if (($line =~ m/====/) || ($line =~ m/Getter/)) {
                next;
            }

            # don't indent lines that are whitespace only
            my $new_line = $line;
            if ($line =~ m/\S/) {
                $new_line = "    " . $line;
            }

            push(@processed_lines, $new_line);
        }
        my $getter_docstring = join("\n", @processed_lines);
        # print "getter_docstring: '\n$getter_docstring'\n";

        # Finally, replace original text with our new function
        $entire_file_text =~ s/$pattern/$substitution/ee;
        # print "new file: \n$entire_file_text\n";
    }

    write_file($filename, $entire_file_text);
}

print "total_matches: '$total_matches'\n";
print "total_replacements: '$total_replacements'\n";
