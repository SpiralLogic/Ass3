#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use File::Copy;


my $metadata_file = "metadata.txt";
open(my $metadata_fh, '<', $metadata_file) or die("Could not find metadata file");

print("Restoring duplicate files\n");

while (my $line = <$metadata_fh>) {
    my @params = split(' ', $line);
    print $params[0] . " " .$params[1] . "\n";
    copy($params[0], $params[1]) or print("Couldn't restore: " . $params[1]);
}