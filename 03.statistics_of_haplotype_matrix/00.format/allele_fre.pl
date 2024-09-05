=pod

The perl is to convert the haplotype matrix to a new format to do the basic statistics

(1) pop_order: population in the haplotype matrix 

format:
wild 
domes

(2) pop_info: sample's information in the haplotype matrix

format: (sampleID population)
s1 wild 
s2 wild
s3 wild
s4 domes
s5 domes
...

(3) grp : the file output via "IntroBlocker Initial_grouping"
Block with "0" indicated missing; Block with other numbers was AHG

(4) output

format:
column 1: chromosome
column 2: window start
column 3: window end
column 4: haplotype (AHG)
column 5: total wild barley accessions with un-missing haplotype in the window
column 6: total wild barley accessions with certain haplotype (column 4) in the window
column 7: frequency of certain haplotype (column 4) in the window for wild barley
column 8: total domesticated barley accessions with un-missing haplotype in the window
column 9: total wild barley accessions with certain haplotype (column 4) in the window 
column 10: frequency of certain haplotype (column 4) in the window for domesticated barley

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 4;

my $pop_order=shift;
my $pop_info=shift;
my $grp=shift; 
my $output=shift;

my @pop;
open IN,$pop_order or die $!;
while (<IN>)
{
    chomp;
    my @a=split;
    push @pop,$a[0];
}
close IN;

my %x;
open IN,$pop_info or die $!;
while (<IN>)
{
    chomp;
    my @a=split;
    $x{$a[0]}=$a[1];
}
close IN;

if ($grp=~/gz$/){open IN,"gzip -dc $grp|" or die $!}
else {open IN,$grp or die $!}
open OUT,"| gzip >$output";
my @h;
for my $p(@pop){push @h,"$p\_unmiss_num\t$p\_num\t$p\_fre"}
my $h=join "\t",@h;
print OUT "CHROM\tstart\tend\ttype\t$h\n";
my $t=<IN>;
chomp $t;
my @t=split /\s+/,$t;
my %index;
for (my $i=3;$i<@t;$i++)
{
    if (exists $x{$t[$i]})
    {
        my $tem_pop=$x{$t[$i]};
        push @{$index{$tem_pop}},$i;
    }
}
while (<IN>)
{
    chomp;
    my @a=split;
    
    my (%total,%type,%all);
    my $test=0;
    for my $tem_pop(sort keys %index)
    {
        my @index=@{$index{$tem_pop}};
        my @AHG=@a[@index];
        for my $el(@AHG)
        {
            next if $el==0;
            $test++;
            $total{$tem_pop}++;
            $type{$el}{$tem_pop}++;
            $all{$el}=1;
        }
    }
    next if $test==0;

    for my $el(sort {$a<=>$b} keys %all)
    {
        my @ln;
        for my $tem_pop(@pop)
        {
            my ($s_num,$pro);
            if (exists $total{$tem_pop})
            {
                if (exists $type{$el}{$tem_pop}){$s_num=$type{$el}{$tem_pop};$pro=sprintf "%.4f",$s_num/$total{$tem_pop}}
                else{$s_num=0;$pro=0}
                push @ln,"$total{$tem_pop}\t$s_num\t$pro";
            }
            else{push @ln,"0\t0\t0"}
        }
        my $ln=join "\t",@ln;
        print OUT "$a[0]\t$a[1]\t$a[2]\t$el\t$ln\n";
    }
}
close IN;
close OUT;
