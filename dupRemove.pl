#!/usr/bin/perl
# Duplicate remover By Solomon Jennings
#
# Removes all of the duplicates in a given directory and creates a metadata.txt which contains the copy that remains
# and the locations of the duplciate
#
# Requires: Digest::MD5::File
# installation by: cpan install Digest::MD5::File
#
# This is achieved in the following way
# 1. Recursive search given folder
# 2. Create an md5 of the file contents and check if it has seen before, if it has then it is a duplciate (2^−128 probability of collision
# 3. Add the orginal and duplicate locations to metadata file
# 4. Remove duplicate files
#

use strict;
use warnings FATAL => 'all';
use File::Find;
use Digest::MD5::File qw(file_md5_hex);
use feature ':5.10';

my %md5s;                           # Associative array of known MD5s and the first file found with that md5
my $metadata_file = "metadata.txt";
# my $file;
# my $md5_key;
my $directory = $ARGV[0];

# Remove metadata file if it already exists
unlink $metadata_file;

if(-e $metadata_file)
{
    print "Could not remove metadata file!";
    exit;
}

# Open metadata file for writing
open(my $metadata_fh, '>', $metadata_file) or die("Could not create metadata file");

# Find all files in the given directory recursively and check them
finddepth({wanted => \&checkFile, no_chdir => 1}, $directory);

# Print all original files found and their md5s
# while (($md5_key, $file) = each(%md5s)) {
#   print $md5_key . " " . $file . "\n";
#}

# Check if a file is already known
sub checkFile {
    my $filename = $_;
    my $filesize = -s $filename;
    my $sizeExists = 0;

    # Skip directories
    if (-d $filename) {
        return;
    }
    my $md5 = file_md5_hex($filename);

    if (!exists($md5s{$md5})) {
        $md5s{$md5} = $filename;
    } else {
        my $line =  $md5s{$md5} . " " . $filename . "\n";
        unlink($filename);
        print $metadata_fh $line;
    }

};