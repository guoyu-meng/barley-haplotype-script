=pod

The perl is to exclude the haplotype wiich is possibly a recent gene flow from domesticated to wild barley

(1) threhold: tolerance percentage  
for a haplotype, when there were wild barleys were from recent times (from second time to fifth time),
if wild sample / domesticated sample < threhold, it is possibly recent gene flow from domesticated to wild; otherwise it is possibly recent gene flow from wild to domesticated

if wild sample / domesticated sample < threhold,then we count the time origin as follows:
if there is wild barleys from old time (first time), use the old time; otherwise convert the haplotype to missing


if wild sample / domesticated sample < threhold, then we count the ancestral origin
if there is wild barleys from old time (first time), use the average ADMIXTURE of those wild barley; otherwise convert the haplotype to missing

(2) fre: output of merge_files.pl

(3) output: same format as fre 

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV !=3;

my $threhold=shift;
my $fre=shift; # raw grp
my $output=shift;

open IN,"gzip -dc $fre|" or die $!;
open OUT,"|gzip >$output";
my $t=<IN>;
chomp $t;
print OUT "$t\n";
while (<IN>)
{
    chomp;
    my @a=split;
    if ($a[5]!=0 && $a[8]!=0)
    {
        my @b=split /,/,$a[11];
        if ($b[0]!=1) # means recent
        {
            if ($a[5]/$a[8]<$threhold) # means wild samples may nest in domesticated samples
            {
                if ($b[0]==0){$a[8]=0;$a[9]=0;$a[11]=0;$a[12]=0;$a[13]=0} # no old haplotype
                else # has old haplotype
                {
                    $a[11]="1.000,0.000,0.000,0.000,0.000";

                    my @c=split /\|/,$a[13]; # WBDC_165:0,0,0,0,1,0:0,0.3553,0,0.6112,0.0335|
                    my (@detail,%tem);
                    for my $el(@c)
                    {
                        my @d=split /:/,$el; 
                        my @ti=split /,/,$d[1];
                        if ($ti[0]==1)
                        {
                            push @detail,$el;
                            my @an=split /,/,$d[2];
                            for (my $i=0;$i<@an;$i++){$tem{$i}+=$an[$i]}
                        }
                    }
                    $a[8]=scalar @detail;
                    $a[9]=sprintf "%.4f",$a[8]/$a[7];
                    $a[13]=join "|",@detail;
                    my $total;
                    for my $num(0..4){$total+=$tem{$num} if exists $tem{$num}}
                    my @pro;
                    for my $num(0..4)
                    {
                        my $pro;
                        if (exists $tem{$num}){$pro=sprintf "%.4f",$tem{$num}/$total}
                        else {$pro=0}
                        push @pro,$pro;
                    }
                    $a[12]=join ",",@pro;
                }
            }
        }
    }
    my $ln=join "\t",@a;
    print OUT "$ln\n";
}
close IN;
close OUT;
