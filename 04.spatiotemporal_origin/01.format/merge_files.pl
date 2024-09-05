=pod

The perl is to merge two files:

grp: output file of spatiotemporal_5time.step2.pl
fre: output file of allele_fre.mark_region.pl

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 3;

my $grp=shift;
my $fre=shift; 
my $output=shift;

my %x;
open IN,"gzip -dc $grp|" or die $!;
<IN>;
while (<IN>)
{
    chomp;
    my @a=split;
    $x{$a[0]}{$a[1]}{$a[3]}="$a[4]\t$a[5]\t$a[6]";
}
close IN;

open IN,"gzip -dc $fre|" or die $!;
open OUT,"| gzip >$output";
my $t=<IN>;
chomp $t;
print OUT "$t\ttime_admix\tances_admix\tdetail\n";
while (<IN>)
{
    chomp;
    my @a=split;
    if (exists $x{$a[0]}{$a[1]}{$a[3]}){print OUT "$_\t$x{$a[0]}{$a[1]}{$a[3]}\n"}
    else {print OUT "$_\t0\t0\t0\n"}
}
close IN;
close OUT;
