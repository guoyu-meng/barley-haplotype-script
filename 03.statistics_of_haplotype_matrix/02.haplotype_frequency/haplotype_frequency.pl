=pod

The perl is to do a statistics of haplotype proportion in different frequency bins

(1) sample_size: total sample in haplotype matrix

(2) max_missing: windows less than certain missing will be excluded

(3) region: R1 (distal), R2 (interstitial), Cen (proximal) or all (entire genome)

(4) min: minimum frequency 

(5) max: maximum frequency

(6) step: bin size

(7) fre: frequnecy file of allele_fre.mark_region.pl

(8) output: output file

4 columns:
column 1: frequency interval ID
column 2: frequency interval
column 3: haplotype proportion in wild barley
column 4: haplotype proportion in domesticated barley

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 8;

my $sample_size=shift; # 367
my $max_missing=shift; # 0.2
my $region=shift;
my $min=shift; #0.00
my $max=shift; #0.50
my $step=shift; #0.05 
my $fre=shift; # 
my $output=shift;

my $min_sample=$sample_size*(1-$max_missing);

my %r;
if ($region eq 'R1'){$r{R1}=1}
elsif ($region eq 'R2'){$r{R2}=1}
elsif ($region eq 'Cen'){$r{Cen}=1}
elsif ($region eq 'all'){$r{R1}=1;$r{R2}=1;$r{Cen}=1}
else{die $!}

my $time=($max-$min)/$step;
my @fre;
for (1..$time)
{
    my $st=sprintf "%.2f",($min+($_-1)*$step);
    my $end=sprintf "%.2f",($st+$step); #print "$_\t$st{$_}\t$end{$_}\n";
    push @fre,"$st-$end";
}

open IN,"gzip -dc $fre|" or die $!;
<IN>;
my (%total,%x);
while (<IN>)
{
    chomp;
    my @a=split; 
    next if ($a[4]+$a[7])<$min_sample;   
    if (exists $r{$a[10]})
    {
        if ($a[5]!=0)
        {
            my $s_num=$a[5];
            my $target_fre;
            for my $fre(@fre)
            {
                my @tem=split /-/,$fre;
                if ($a[6]>$tem[0] && $a[6]<=$tem[1]){$target_fre=$fre;last}
            }
            for my $num(1..$s_num)
            {
                $total{wild}++;
                $x{$target_fre}{wild}++;
            }
        }
        if ($a[8]!=0)
        {
            my $s_num=$a[8];
            my $target_fre;
            for my $fre(@fre)
            {
                my @tem=split /-/,$fre;
                if ($a[9]>$tem[0] && $a[9]<=$tem[1]){$target_fre=$fre;last}
            }
            for my $num(1..$s_num)
            {
                $total{domes}++;
                $x{$target_fre}{domes}++;
            }
        }
    }
}
close IN;

open OUT,">$output";
print OUT "#num\tinterval\twild\tdomes\n";
my $n;
for my $fre(@fre)
{
    $n++;
    my @ln;
    for my $p("wild","domes")
    {
        my $v;
        if (exists $x{$fre}{$p}){$v=$x{$fre}{$p}}
        else {$v=0}
        my $pro=$v/$total{$p};
        push @ln,$pro;
    }
    my $ln=join "\t",@ln;
    print OUT "$n\t$fre\t$ln\n";
}
close OUT;
