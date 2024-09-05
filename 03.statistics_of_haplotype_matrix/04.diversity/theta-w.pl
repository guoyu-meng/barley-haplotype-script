=pod

The perl is to calculate Watterson estimator based on haplotype matrix 

detailed for Watterson estimator:
Watterson G A. On the number of segregating sites in genetical models without recombination. Theoretical population biology 1975

(1) grp : the file output via "IntroBlocker Initial_grouping" or "keep.pl"
Block with "0" indicated missing; Block with other numbers was AHG

(2) max_missing: the maximum missing rate of the window. Window more than the missing rate will be excluded. 

(3) output: output file

4 columns.
column 1: chromosome
column 2: window start
column 3: window end
column 4: Watterson estimator value

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
open OUT,">$output" or die $!;
<IN>;
print OUT "#chr\tst\tend\tvalue\n";
while (<IN>)
{
    chomp;
    my @a=split;

    my $miss=0;
    for (my $i=3;$i<@a;$i++){$miss++ if $a[$i]==0}
    next if $miss/(@a-3) > $max_missing;

    my $sample_num=0;
    my %geno;
    for (my $i=3;$i<@a;$i++)
    {
        if ($a[$i]!=0){$geno{$a[$i]}=1;$sample_num++}
    }    
    my $k=scalar keys %geno;
    my $theta_w;
    if ($k==1){$theta_w=0}
    else
    {
        $theta_w=theta_w($k,$sample_num);
    }
    print OUT "$a[0]\t$a[1]\t$a[2]\t$theta_w\n";
}
close IN;
close OUT;

sub theta_w
{
    die $! if @_!=2;
    my $k=$_[0];
    my $n=$_[1];
    my $fenmu;
    for my $num(1..$n-1){$fenmu+=1/$num}
    my $value=$k/$fenmu;
    return $value;
}    
