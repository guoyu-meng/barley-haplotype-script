=pod

The perl is to calculate Shannon diversity index based on haplotype matrix

detailed for Shannon diversity index:
Shannon (1916–2001) and a plea for more rigorous use of species richness, species diversity and the ‘Shannon–Wiener’ Index. Global Ecology and Biogeography 12, 177-179 (2003). 

(1) grp : the file output via "IntroBlocker Initial_grouping" or "keep.pl"
Block with "0" indicated missing; Block with other numbers was AHG

(2) max_missing: the maximum missing rate of the window. Window more than the missing rate will be excluded.

(3) output: output file

4 columns.
column 1: chromosome
column 2: window start
column 3: window end
column 4: Shannon diversity index value

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 3;

my $grp=shift;
my $max_missing=shift;
my $output=shift;

if ($grp=~/gz$/){open IN,"gzip -dc $grp|" or die $!}
else{open IN,$grp or die $!}
open OUT,">$output";
<IN>;
print OUT "CHROM\tstart\tend\tvalue\n";
while (<IN>)
{
    chomp;
    my @a=split;

    my %x;
    my $miss=0;
    for (my $i=3;$i<@a;$i++)
    {
        if ($a[$i]!=0){$x{$a[$i]}++}
        else{$miss++}
    }
    next if $miss/(@a-3) > $max_missing;

    my $totle_num=@a-3-$miss;

    my $sum;
    for my $hap(sort keys %x)
    {
        my $pi=$x{$hap}/$totle_num;
        my $log=log($pi)/log(2);
        $sum+=$pi*$log;
    }
    my $value=$sum*(-1);
    print OUT "$a[0]\t$a[1]\t$a[2]\t$value\n";
}
close IN; 
close OUT;   
