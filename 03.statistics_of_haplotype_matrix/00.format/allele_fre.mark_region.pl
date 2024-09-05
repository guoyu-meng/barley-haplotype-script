=pod

the perl is just to add a region to the output file of allele_fre.pl 

(1) region_info

format:
chr1H R1a:0-50 R2a:50-100 C:100-290 R2b:290-470 R1b:470-516

where R1: distal; R2: interstitial; C: proximal (or pericentromeric).
0-50 means 0Mb to 50Mb

(2) fre: output file of allele_fre.pl

(3) output:

region column include three types: R1 (distal), R2 (interstitial) and Cen (proximal)

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 3;

my $region_info=shift;
my $fre=shift; 
my $output=shift;

my %r;
open IN,$region_info or die $!;
while (<IN>)
{
    chomp;
    my @a=split;
    for (my $i=1;$i<@a;$i++)
    {
        my @b=split /:/,$a[$i];
        my @c=split /-/,$b[1];
        $c[1]++ if $i==5; 
        my $key="$c[0]\t$c[1]";
        if ($i==1){$r{$key}="R1"}
        elsif ($i==2){$r{$key}="R2"}
        elsif ($i==3){$r{$key}="Cen"}
        elsif ($i==4){$r{$key}="R2"}
        elsif ($i==5){$r{$key}="R1"}
    }
}
close IN;

open IN,"gzip -dc $fre|" or die $!;
open OUT,"| gzip > $output";
my $t=<IN>;
chomp $t;
print OUT "$t\tregion\n";
while (<IN>)
{
    chomp;
    my @a=split;
    my $ave=(($a[1]+$a[2])/2)/1000000;
    my $r;
    for my $key(sort keys %r)
    {
        my @pos=split /\t/,$key;
        if ($ave>=$pos[0] && $ave<$pos[1]){$r=$r{$key};last}
    }
    print OUT "$_\t$r\n";    
}
close IN;
close OUT;
