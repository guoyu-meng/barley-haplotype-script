#warning: the output files should be less than 1024 (linux limitaiton)

=pod
the perl is to split file based on a list
eg. list
1
2
eg.input
1 a
1 b
2 c
2 d
eg.ouput
file:1.gz 
1 a
1 b
file2:2.gz
2 c
2 d
=cut

#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Std;
use IO::Compress::Gzip qw(gzip $GzipError);

die("
Usage:   perl file_split.list.pl -L list -I input -C column [-H] -o out_dir
Options:
         -L STRING    a list file
         -I STRING    input file
         -C INT       the column where the flag is in 
         -H           if the input has the header
         -o STRING    the output directory
\n") unless (@ARGV); 

my %opts;
getopts('L:I:C:Ho:',\%opts);

if (not exists $opts{L}){die "-L: not in"}
if (not exists $opts{I}){die "-I: not in"}
if (not exists $opts{C}){$opts{C}=1}
if (not exists $opts{o}){$opts{o}='./'}

my $line=`wc -l $opts{L}`;
chomp $line;
my $line_num=(split /\s+/,$line)[0];
#die "#list was too more" if $line_num >=200;

my %x;
open IN,$opts{L};
while (<IN>)
{
    chomp;
    my @a=split;
    my $fh = new IO::Compress::Gzip "$opts{o}/$a[0].gz";
    print $fh "";
    $x{$a[0]}=$fh;
}
close IN;

if ($opts{I}=~/gz$/){open IN,"gzip -dc $opts{I} | grep -v \"^##\" |" or die $!}    
else {open IN,"$opts{I} | grep -v \"^##\" |" or die $!}
if ($opts{H})
{
    my $t=<IN>;
    for (sort keys %x){my $fh=$x{$_};print $fh "$t"}
}
while (<IN>)
{
    chomp;
    my @a=split;
    my $column=$opts{C};
    if (exists $x{$a[$column-1]})
    {
        my $fh=$x{$a[$column-1]}; 
        print $fh "$_\n";
    }    
}
close IN;

for (sort keys %x){my $fh=$x{$_};close $fh}
