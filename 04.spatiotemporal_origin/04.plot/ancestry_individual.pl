=pod

The perl is to calculate the time origin of a certain domesticated barley.

(1) sample: sample ID of a domesticated barley
(2) window_size: window size (e.g. 20Mb) for visualization. we will calculated the average value of a given window size.
(3) fre: output file of recent_gene_flow_filter.pl
(4) grp: output file of spatiotemporal_5time.step1.pl
(5) output: 5 ancestry contribution in different window

Unknown: missing data, haplotype not shared with wild or recent gene flow from domesticated to wild

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV !=5;

my $sample=shift;
my $window_size=shift;
my $fre=shift;
my $grp=shift; # raw grp
my $output=shift;

my %x;
open IN,"gzip -dc $fre|" or die $!;
<IN>;
while (<IN>)
{
    chomp;
    my @a=split;
    if ($a[5]!=0 && $a[8]!=0)
    {
        $x{$a[0]}{$a[1]}{$a[3]}=$a[12];
    }
}
close IN;

open IN,"gzip -dc $grp|" or die $!;
my $t=<IN>;
chomp $t;
my @t=split /\t/,$t;
my $index;
for (my $i=3;$i<@t;$i++){$index=$i if $t[$i] eq $sample}

my (%y,%unknown);
while (<IN>)
{
    chomp;
    my @a=split;

    my $win=int($a[1]/$window_size)+1;
    
    my $hap=(split /\|/,$a[$index])[0]; #  0|0 or 77|0 or 30|WBDC_341:0,0,1,0,0,0:0,0.6829,0,0.3073,0.0097|xx

    if (exists $x{$a[0]}{$a[1]}{$hap})
    {
        my @tem=split /,/,$x{$a[0]}{$a[1]}{$hap};
        for (my $i=0;$i<@tem;$i++){$y{$win}{$i}+=$tem[$i]}
    }
    else{$unknown{$win}++}
}
close IN;

open OUT,">$output";
print OUT "#win\tunknown\tances0\tances1\tances2\tances3\tances4\n";
my @win=sort {$a<=>$b} keys %y;
pop @win;
for my $win(@win)
{
    my $pos=(($win-1)*$window_size)+1; #print "$pos\n";

    my $total1;
    if (exists $unknown{$win}){$total1=$unknown{$win}}
    else {$total1=0}

    my $total2;
    for my $num(0..4){$total2+=$y{$win}{$num} if exists $y{$win}{$num}}

    my $total=$total1+$total2;
    my $pro_unknown=$total1/$total;
    $pro_unknown=sprintf "%.4f",$pro_unknown;

    my @ln;
    for my $num(0..4)
    {
        my $pro;
        if (exists $y{$win}{$num}){$pro=$y{$win}{$num}/$total}
        else {$pro=0}
        $pro=sprintf "%.4f",$pro;
        push @ln,$pro;
    }
    my $ln=join "\t",@ln;
    print OUT "$pos\t$pro_unknown\t$ln\n";
}
close OUT;
