# the perl is to output a squared file of SNP number
# the plink input was produced by "plink2 --sample-diff counts-only counts-cols=ibs0,ibs1 ids=s1 s2 s3 .."

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 3;

my $sample_info=shift; # sample list
my $plink_sdiff_file=shift; #plink output of --sdiff
my $output=shift;

my (@s,%x);
my $index=0;
open IN,$sample_info or die $!;
while (<IN>)
{
    chomp;
    my @a=split;
    push @s,$a[0];
    $x{$a[0]}=$index;
    $index++;
}
close IN;

my %y;
open IN,$plink_sdiff_file or die $!;
<IN>;
while (<IN>)
{
    chomp;
    my @a=split;
    if (exists $x{$a[0]} && exists $x{$a[1]})
    {
        my $in1=$x{$a[0]};
        my $in2=$x{$a[1]};
        $y{$in1}{$in2}=$a[2]+($a[3]/2);
        $y{$in2}{$in1}=$a[2]+($a[3]/2);
    }
}
close IN;

open OUT,">$output";
for (my $i=0;$i<@s;$i++)
{
    my @ln;
    for (my $j=0;$j<@s;$j++)
    {
        if ($i==$j){push @ln,"0"}
        else{push @ln,$y{$i}{$j}}
    }
    my $ln=join "\t",@ln;
    print OUT "$ln\n";
}
close OUT;
