=pod

The perl is to keep the certain sample in haplotype matrix

(1) sample_info : sample ID list 

(2) grp : the file output via "IntroBlocker Initial_grouping"
Block with "0" indicated missing; Block with other numbers was AHG

(3) output: new grp file

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 3;

my $sample_info=shift;
my $grp=shift;
my $output=shift;

my %x;
open IN,$sample_info or die $!;
while (<IN>)
{
    chomp;
    my @a=split;
    $x{$a[0]}=1;
}
close IN;

if ($grp=~/gz$/){open IN,"gzip -dc $grp|" or die $!}
else{open IN,$grp or die $!}
open OUT,"| gzip >$output";
my $t=<IN>;
chomp $t;
my @t=split /\s+/,$t;
my (@h,@index);
for (my $i=3;$i<@t;$i++)
{
    my $sample=$t[$i];
    if (exists $x{$sample})
    {
        push @h,$sample;
        push @index,$i;
    }
}
my $h=join "\t",@h;
print OUT "CHROM\tstart\tend\t$h\n";
while (<IN>)
{
    chomp;
    my @a=split;
    my @b=@a[@index];
    my $ln=join "\t",@b;
    print OUT "$a[0]\t$a[1]\t$a[2]\t$ln\n";
}
close IN; 
close OUT;   
