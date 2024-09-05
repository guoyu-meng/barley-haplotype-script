=pod

The perl is to calculate the time contribution from wild to domesticated 

(1) region: R1: distal; R2: interstitial; C: proximal (or pericentromeric), all (entire genome)

(2) fre : output file of recent_gene_flow_filter.pl

(3) output: contribution from 5 time 

=cut


#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV !=3;

my $region=shift;
my $fre=shift; # filter.gz
my $output=shift;

my %r;
if ($region eq 'R1'){$r{R1}=1}
elsif ($region eq 'R2'){$r{R2}=1}
elsif ($region eq 'Cen'){$r{Cen}=1}
elsif ($region eq 'all'){$r{R1}=1;$r{R2}=1;$r{Cen}=1}
else{die $!}

my %x;
open IN,"gzip -dc $fre|" or die $!;
<IN>;
while (<IN>)
{
    chomp;
    my @a=split;
    next if not exists $r{$a[10]};

    if ($a[5]!=0 && $a[8]!=0)
    {
        next if $a[11] eq '0';
        my @b=split /,/,$a[11];
        my @index;
        for (my $i=0;$i<@b;$i++){push @index,$i if $b[$i]!=0}
        my @new=reverse @index;
        my $time=$new[0];        
        for my $num(1..$a[8]){$x{$time}++}
    }
}
close IN;

open OUT,">$output";
my $sum;
for my $i(sort {$a<=>$b} keys %x){$sum+=$x{$i}}
for my $i(sort {$a<=>$b} keys %x)
{
    my $num=$i+1;
    my $pro=$x{$i}/$sum;
    print OUT "$num\t$pro\n";
}
close OUT;
