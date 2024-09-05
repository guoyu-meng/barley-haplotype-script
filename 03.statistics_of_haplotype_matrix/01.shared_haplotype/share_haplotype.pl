=pod

The perl is to do a statistics of shared haplotype

(1) sample_size: total sample in haplotype matrix

(2) max_missing: windows less than certain missing will be excluded

(3) region: R1 (distal), R2 (interstitial), Cen (proximal) or all (entire genome)

(4) fre: frequnecy file of allele_fre.mark_region.pl

(5) output: output file

4 rows:
row 1: total windows number
row 2: total haplotypes number in wild barley
row 3: total haplotypes number in domesticated barley
row 4: shared haplotypes number

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 5;

my $sample_size=shift; # 367
my $max_missing=shift; # 0.2
my $region=shift;
my $fre=shift; 
my $output=shift;

my $min_sample=$sample_size*(1-$max_missing);

my %r;
if ($region eq 'R1'){$r{R1}=1}
elsif ($region eq 'R2'){$r{R2}=1}
elsif ($region eq 'Cen'){$r{Cen}=1}
elsif ($region eq 'all'){$r{R1}=1;$r{R2}=1;$r{Cen}=1}
else{die $!}


my (%win,$total_wild,$total_domes,$total_share);
open IN,"gzip -dc $fre|" or die $!;
<IN>;
while (<IN>)
{
    chomp;
    my @a=split; 
    next if ($a[4]+$a[7])<$min_sample;

    if (exists $r{$a[10]})
    {
        my $window_ID="$a[0]_$a[1]";
        $win{$window_ID}=1;

        if ($a[5]!=0){$total_wild++}
        if ($a[8]!=0){$total_domes++}
        if ($a[5]!=0 && $a[8]!=0){$total_share++}
    }
}
close IN;

my $total_window=scalar keys %win;
open OUT,">$output";
print OUT "total_window\t$total_window\ntotal_wild\t$total_wild\ntotal_domes\t$total_domes\ntotal_share\t$total_share\n";
close OUT;
