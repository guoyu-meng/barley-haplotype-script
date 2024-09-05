=pod
the perl is to convert samtools depth file to BED format for saving space

input yield by: samtools -depth bam 
chr1     1	1
chr1     2      1
chr1     3      1
chr1     7      1
chr1     8      1
chr1     9      1
chr1     12     2
chr1     13     2
chr1     14     2
chr2     1      2
chr2     2      2

output:
chr1    1	3     1
chr1    7	9     1
chr1    12	14   2
chr2    1	2     2
=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 2;

my $depth=shift;
my $output=shift;

my ($last_chr,$st,$last_pos,$last_depth);

open IN,"gzip -dc $depth|" or die $!;
open OUT,"|gzip > $output";
while (<IN>)
{
    chomp;
    my @a=split;
    if (!$last_chr)
    {
        $last_chr=$a[0];
        $st=$a[1];
        $last_pos=$a[1];
        $last_depth=$a[2];
        next;
    }
    if ($a[0] eq $last_chr)
    {
        if ($a[2] eq $last_depth)
        {
            if ($a[1]-$last_pos>1)
            {
	        print OUT "$last_chr\t$st\t$last_pos\t$last_depth\n";
                $st=$a[1];
            }
        }
        else
        {
	    print OUT "$last_chr\t$st\t$last_pos\t$last_depth\n";
            $st=$a[1];
        }
    }
    else
    {
        print OUT "$last_chr\t$st\t$last_pos\t$last_depth\n";
        $st=$a[1];
    }
    $last_chr=$a[0];
    $last_pos=$a[1];
    $last_depth=$a[2];    
}
print OUT "$last_chr\t$st\t$last_pos\t$last_depth\n";
close IN;
close OUT;    
