=pod

(1) pop_info: the sample order used for Introblocker run
two columns: 
1st column: sample ID
2nd column: must be "wild" or "domes"

(2) grp: the file output via "IntroBlocker Initial_grouping"
Block with "0" indicated missing; Block with other numbers was AHG

(3) output: only domesticated barley were kept
x|0 
x: haplotype
0: no wild barley shared the haplotype

x|WBDC_070,WBDC_303
x: haplotype
0: wild barley WBDC_070 and WBDC_303 shared the haplotype
 
=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV !=3;

my $pop_info=shift; # two columns: must be "wild" and "domes"
my $grp=shift; # haplotype matrix by "IntroBlocker Initial_grouping"
my $output=shift;

my %x;
open IN,$pop_info or die $!;
while (<IN>)
{
    chomp;
    my @a=split;
    $x{$a[0]}=$a[1]; #print "$a[0]\t$a[1]\n";
}
close IN;

if ($grp=~/gz$/){open IN,"gzip -dc $grp|" or die $!}
else {open IN,$grp or die $!}
open OUT,"|gzip >$output";
my $t=<IN>;
chomp $t;
my @t=split /\s+/,$t;
my (@index_w,@index_d);
for (my $i=3;$i<@t;$i++)
{
    my $s=$t[$i];
    die "$s\n" if not exists $x{$s};
    if ($x{$s} eq 'wild'){push @index_w,$i}
    elsif ($x{$s} eq 'domes'){push @index_d,$i}
    else{die $!}
}
my @t_domes=@t[@index_d];
my $t_domes=join "\t",@t_domes;
print OUT "$t[0]\t$t[1]\t$t[2]\t$t_domes\n";
while (<IN>)
{
    chomp;
    my @a=split;
    for my $id(@index_d)
    {
        my $gd=$a[$id];
        if ($gd==0){$a[$id]="$gd|0"}
        else
        {
            my $test=0;
            my @sw;
            for my $iw(@index_w)
            {
                my $gw=$a[$iw];
                if ($gw==$gd){my $s=$t[$iw];push @sw,$s;$test++}
            }
            if ($test==0){$a[$id]="$gd|0"}
            else
            {
                my $sw=join ",",@sw;
                $a[$id]="$gd|$sw";
            }
        }
    }   
    my @gd=@a[@index_d];
    my $ln_gd=join "\t",@gd;    
    print OUT "$a[0]\t$a[1]\t$a[2]\t$ln_gd\n";
}
close IN;
close OUT;
