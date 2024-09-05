=pod

The perl is to do a statistics of two-dimensional haplotype frequency spectrum 

(1) sample_size: total sample in haplotype matrix

(2) max_missing: windows less than certain missing will be excluded

(3) region: R1 (distal), R2 (interstitial), Cen (proximal) or all (entire genome)

(4) min: minimum frequency 

(5) max: maximum frequency

(6) step: bin size

(7) fre: frequnecy file of allele_fre.mark_region.pl

(8) output: output file

each row: haplotype frequency bin in wild barley
each column: haplotype frequency bin in domesticated barley

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
my ($total,%x);
while (<IN>)
{
    chomp;
    my @a=split; 
    next if ($a[4]+$a[7])<$min_sample;   
    if (exists $r{$a[10]})
    {
        if ($a[5]!=0 && $a[8]!=0)
        {
            $total++;
            my $target_fre_wild;
            for my $fre(@fre)
            {
                my @tem=split /-/,$fre;
                if ($a[6]>$tem[0] && $a[6]<=$tem[1]){$target_fre_wild=$fre;last}
            }

            my $target_fre_domes;
            for my $fre(@fre)
            {
                my @tem=split /-/,$fre;
                if ($a[9]>$tem[0] && $a[9]<=$tem[1]){$target_fre_domes=$fre;last}
            }

            $x{$target_fre_wild}{$target_fre_domes}++;                        
        }
    }
}
close IN;

my @t;
for my $fre(@fre){push @t,$fre}
my $h=join "\t",@t;

open OUT,">$output";
print OUT "bin\t$h\n";
for (my $i=0;$i<@fre;$i++)
{
    my @ln;
    for (my $j=0;$j<@fre;$j++)
    {
        my $key1=$fre[$i];
        my $key2=$fre[$j];

        my $pro;
        if (exists $x{$key1}{$key2}){$pro=$x{$key1}{$key2}/$total}
        else {$pro=0}
        $pro=sprintf "%.4f",$pro;
        push @ln,$pro;
    }
    my $ln=join "\t",@ln;    
    print OUT "$fre[$i]\t$ln\n";
}
close OUT;
