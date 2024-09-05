#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 3;

my $paired_ECR=shift;
my $dis_square=shift;
my $output=shift;

my %ECR;
my $row=0;
open IN,$paired_ECR or die $!;
while (<IN>)
{
    chomp;
    my @a=split;
    for (my $i=0;$i<@a;$i++){$ECR{$row}{$i}=$a[$i]}   
    $row++;
}
close IN;

$row=0;
open IN,$dis_square or die $!;
open OUT,">$output" or die $!;
while (<IN>)
{
    chomp;
    my @a=split;
    for (my $i=0;$i<@a;$i++)
    {
        if ($ECR{$row}{$i}==0){$a[$i]=0}
        else{$a[$i]=int(($a[$i]/$ECR{$row}{$i})*1000000)};
    }
    my $ln=join "\t",@a;
    print OUT "$ln\n";
    $row++;
}
close IN;
close OUT;
