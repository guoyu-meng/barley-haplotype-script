=pod
the perl is used to extract SNP number form the square matrix (e.g. from 01.snp_number_calculation/04.snp_number_normalization/1.dist.txt). For each specified window in the window list and each pair of samples in the specified sample list, the SNP number in each window will be extracted and output to a file.

The output could be used for calculate the SNP number distribution

(1) target_sample_list:  one column. one sample in a row.
format:
s2
s3
s5

(2) raw_sample_list: one column. the original sample list used to calculate the SNP number (the original sample order).
format:
s1
s2
s3
s4
s5

(3) raw_dis_list: 4 columns. chromosome, window start, window end and SNP number file path in a row 
format:
chr1H 1 1000000 XX/chr1H/1.dist.txt
chr1H 200000 1200000 XX//2.dist.txt
chr2H 1 1000000 XX/chr2H/1.dist.txt
chr2H 200000 1200000 XX/chr2H/2.dist.txt

(4) output (compress format): 6 columns. chromosome, window st, window end, sample1, sample2, SNP number
format:

chr1H 1 1000000 s2 s3 x
chr1H 1 1000000 s2 s5 x
chr1H 1 1000000 s3 s5 x
chr1H 200000 1200000 s2 s3 x
chr1H 200000 1200000 s2 s5 x
chr1H 200000 1200000 s3 s5 x

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 4;

my $target_sample_list=shift;
my $raw_sample_list=shift;
my $raw_dis_list=shift;
my $output=shift;

my %s;
open IN,$target_sample_list or die $!;
while (<IN>)
{
    chomp;
    my @a=split;
    $s{$a[0]}=1;
}
close IN;

my %index;
my $n=0;
open IN,$raw_sample_list or die $!;
while (<IN>)
{
    chomp;
    my @a=split;
    if (exists $s{$a[0]}){$index{$n}=$a[0]}
    $n++;
}
close IN;

open OUT,"| gzip >$output";

open IN,$raw_dis_list or die $!;
while (<IN>)
{
    chomp;
    my @a=split;

    my %tem;
    $n=0;
    open IN1,$a[3] or die $!;
    while (my $ln=<IN1>)
    {
        if (exists $index{$n})
        {
            chomp $ln;
            my @b=split /\s+/,$ln;
            for (my $i=0;$i<@b;$i++)
            {
                next if $i <= $n;
                if (exists $index{$i})
                {
                    if (not exists $tem{$n}{$i} && not exists $tem{$i}{$n})
                    {
                        print OUT "$a[0]\t$a[1]\t$a[2]\t$index{$n}\t$index{$i}\t$b[$i]\n";
                        $tem{$n}{$i}=1;
                    }
                }
            }
        }
        $n++;
    }
    close IN1;
}
close IN;
close OUT;
