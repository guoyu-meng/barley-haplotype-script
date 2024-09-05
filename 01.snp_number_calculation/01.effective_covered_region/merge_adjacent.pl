=pod

the input was depth file with bed format

e.g.

chr1H   51182   51224   2
chr1H   51225   51242   3
chr1H   51243   51269   2
chr1H   51270   51332   3
chr1H   51333   51355   2

will be 

chr1H 51182 51355

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 2;

my $depth_bed=shift;
my $output=shift;

my ($last_chr,$st,$end);
open IN,"gzip -dc $depth_bed|" or die $!;
open OUT,"|gzip > $output";
while (<IN>)
{
    chomp;
    my @a=split;
    if (!$last_chr)
    {
        $last_chr=$a[0];
        $st=$a[1];
        $end=$a[2];
        next;
    }

    if ($a[0] eq $last_chr)
    {
        if ($a[1]-$end>1)
        {
	    print OUT "$last_chr\t$st\t$end\n";
            $st=$a[1];
        }
        elsif ($a[1]-$end==1)
        {
            $last_chr=$a[0];
        }
        else {die $!}
    }
    else
    {
        print OUT  "$last_chr\t$st\t$end\n";
        $st=$a[1];
    }
    $last_chr=$a[0];
    $end=$a[2];    
}
print OUT "$last_chr\t$st\t$end\n";
close IN;
close OUT;    
