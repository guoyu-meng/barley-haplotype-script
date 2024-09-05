=pod
The perl is to convert the data1 (such as phased SNP data) to data2 for Gnuplot heatmap plot 

data1
sample1 1 0 0 0
sample2 0 1 1 1
sample3 1 0 0 1

data2
0 0 1
0 1 0
0 2 1
1 0 0
1 1 1
1 2 0
2 0 0
2 1 1
2 2 0
3 0 1
3 1 1
3 2 0

Then you can use the following command for plotting in Gnuplot: plot 'data2' using 1:2:3 with image

Perl usage: perl three_column_for_heatmap.pl 1 data1 data2
=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 3;

my $h=shift; # 0 no header; 1 header
my $data1=shift; # input
my $data2=shift; # output

my (%data,$column,$row);

if ($data1=~/gz$/){open IN,"gzip -dc $data1|" or die $!}
else{open IN,$data1 or die $!}
<IN> if $h==1;
while (<IN>)
{
     $row++;
     chomp;
     my @a=split;
     my $sample=shift @a;
     @{$data{$row}}=@a;
     $column=@a;
}
close IN;

open OUT,">$data2";
for my $x(0..$column-1)
{
    my $y=0;
    for my $tem_row(sort {$b<=>$a} keys %data)
    {
        my $value=$data{$tem_row}[$x];
	print OUT "$x $y $value\n";
        $y++;
    }
}
close OUT;
