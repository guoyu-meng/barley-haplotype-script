=pod

The perl is to calculate absolute allele frequency difference (AFD) between two populations based on haplotype matrix

detailed for AFD:
Berner, D. Allele Frequency Difference AFD–An Intuitive Alternative to FST for Quantifying Genetic Population Differentiation. Genes 10, 308 (2019).

(1) max_missing: the maximum missing rate (for both two populations) of the window. Window with any population more than the missing rate will be excluded.

(2) pop_info: sample information with population ID
2 columns:
column 1: sample ID
column 2: population ID

(3) grp : the file output via "IntroBlocker Initial_grouping"
Block with "0" indicated missing; Block with other numbers was AHG

(4) output: output file

4 columns.
column 1: chromosome
column 2: window start
column 3: window end
column 4: AFD value

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 4;

my $max_missing=shift; # max missing in subpopulation
my $pop_info=shift; # two column each row: sample_id pop_info
my $grp=shift;
my $output=shift;

my (%x,%y);
open IN,$pop_info or die $!;
while (<IN>)
{
    chomp;
    my @a=split;
    push @{$x{$a[1]}},$a[0];
    $y{$a[0]}=$a[1];
}
close IN;
my @p=sort keys %x;
die "not two populations\n" if @p!=2;
my $p1=$p[0];
my $p2=$p[1];

if ($grp=~/gz$/){open IN,"gzip -dc $grp|" or die $!}
else{open IN,$grp or die $!}
open OUT,">$output";
print OUT "CHROM\tstart\tend\tvalue\n";

my $t=<IN>;
chomp $t;
my @t=split /\s+/,$t;

my (@index1,@index2);
for (my $i=3;$i<@t;$i++)
{
    my $s=$t[$i];
    if (exists $y{$s})
    {
        if ($y{$s} eq $p1){push @index1,$i}
        elsif ($y{$s} eq $p2){push @index2,$i}
        else {die $!}
    }
}
while (<IN>)
{
    chomp;
    my @a=split;

    my $g1=join "\t",@a[@index1];
    my $g2=join "\t",@a[@index2];

    my $afd=afd($g1,$g2);
    if ($afd ne 'nan'){print OUT "$a[0]\t$a[1]\t$a[2]\t$afd\n"}
}
close IN; 
close OUT;

sub afd
{
    my @g1=split "\t",$_[0];
    my @g2=split "\t",$_[1];;

    my (%hap1,%hap2,%all);

    my $total1=0;
    my $miss1=0;
    for my $hap(@g1)
    {
        $total1++;
        if ($hap eq 0){$miss1++}
        else
        {
            $hap1{$hap}++;
            $all{$hap}=1;
        }
    }

    my $total2=0;
    my $miss2=0;
    for my $hap(@g2)
    {
        $total2++;
        if ($hap eq 0){$miss2++}
        else
        {
            $hap2{$hap}++;
            $all{$hap}=1;
        }
    }

    if ($total1==0 or $total2==0){return "nan"} 
    else
    {
        my $miss1_pro=$miss1/$total1;
        my $miss2_pro=$miss2/$total2;
        if ($miss1_pro>$max_missing or $miss2_pro>$max_missing){return "nan"}
        else
        {
            my $sum;
            for my $hap(sort {$a<=>$b} keys %all)
            {
                my ($fre1,$fre2);
                if (exists $hap1{$hap}){$fre1=$hap1{$hap}/$total1}
                else{$fre1=0}
                if (exists $hap2{$hap}){$fre2=$hap2{$hap}/$total2}
                else{$fre2=0}
                $sum+=abs($fre1-$fre2);
            }
            my $afd=$sum/2;            
            return $afd;
        }
    }
}             
