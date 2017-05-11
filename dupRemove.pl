#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use File::Find;
use Digest::MD5::File qw(file_md5_hex);
use feature ':5.10';

my %md5s;
my @filesizes_array;
my $metadata_file = "metadata.txt";
my $file;
my $md5_key;

unlink $metadata_file;

if(-e $metadata_file)
{
    print "Could not remove metadata file!";
    exit;
}
open(my $metadata_fh, '>', $metadata_file) or die("Could not create metadata file");


finddepth({wanted => \&checkFile, no_chdir => 1}, $ARGV[0]);


while (($md5_key, $file) = each(%md5s)) {
    print $md5_key . " " . $file . "\n";
}

sub checkFile {
    my $filename = $_;
    my $filesize = -s $filename;
    my $sizeExists = 0;

    if (-d $filename) {
        return;
    }

    foreach my $i (@filesizes_array) {
        if ($i == $filesize) {
            $sizeExists = 1;
            last;
        }
    }

    my $md5 = file_md5_hex($filename);

    if ($sizeExists) {
        if (!exists($md5s{$md5})) {
            $md5s{$md5} = $filename;
        } else {
            my $line = $md5s{$md5} . " " . $filename . "\n";
            unlink($filename);
            print $metadata_fh $line;
        }
    } else {
        $md5s{$md5} = $filename;
        push(@filesizes_array, $filesize);
    }

};