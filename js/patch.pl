#!/usr/bin/perl

use warnings;
use strict;
use File::Find;
use Cwd;

my $current_dir = getcwd();
my @files;
find(
    {
        wanted => sub { push @files, $_ if -f $_ and /\.ml$/i },
        no_chdir => 1,
    },
    $current_dir
    );

foreach my $file (@files) {

    if ($file =~ /jsComp.ml/) {
        next;
    }

    open my $in,  '<',  $file      or die "Can't read old file: $!";
     my $content = "";
    while( <$in> )
    {
        $content .= $_;
    }
    close $in;

    open my $out, '>', $file or die "Can't write new file: $!";
    print $out "open JsComp\n" . $content;
    close $out;
}
