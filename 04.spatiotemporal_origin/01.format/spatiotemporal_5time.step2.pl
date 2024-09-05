=pod

The perl is to calculated the spatiotemporal origin for each haplotype. A haplotype was shared by more than 1 wild barley, the spatiotemporal origin was the average value of those wild barleys.  

(1) grp: output of spatiotemporal_5time.step1.pl  

(2) output:
7 columns.
column 1: chromosome
column 2: window start
column 3: window end
column 4: haplotype
column 5: wild proportion in 5 time. e.g. 0.000,0.250,0.750,0.000,0.000. 25% shared wild barley come from second time; 75% shared wild barley come from third time   
column 6: average ancestral. e.g. 0.225,0.562,0.031,0.030,0.152. average ancestral information of all shared wild barley. 
column 7: detailed wild barley (same as spatiotemporal_5time.step1.pl).

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 2;

my $grp=shift;
my $output=shift;

my %x;
open IN,"gzip -dc $grp|" or die $!;
open OUT,"| gzip >$output";
print OUT "CHROM\tstart\tend\ttype\ttime_admix\tances_admix\tdetail\n";
<IN>;
while (<IN>)
{
    chomp;
    my @a=split;
    my %tem;
    for (my $i=3;$i<@a;$i++)
    {
        my @b=split /\|/,$a[$i];  # 30|WBDC_165:0,0,0,0,1,0:0,0.3553,0,0.6112,0.0335|WBDC_079:0,0,0,0,0,1:0.9159,0,0,0,0.0841
        next if $b[1] eq '0';

        my $hap=shift @b;
        next if exists $tem{$hap};
        $tem{$hap}=1;
        
        my ($sum,%time,%ances);
        for my $el(@b) # WBDC_308:1,0,0,0,0:0,0,1,0,0|5
        {
            $sum++;
                
            my @c=split /\:/,$el;
            
            my @ti=split /,/,$c[1];
            for (my $j=0;$j<@ti;$j++){$time{$j}+=$ti[$j]}

            my @an=split /,/,$c[2];
            for (my $j=0;$j<@an;$j++){$ances{$j}+=$an[$j]}
        }
        
        my @ln_time;
        for my $j(sort {$a<=>$b} keys %time)
        {
            my $pro=sprintf "%.3f",$time{$j}/$sum;
            push @ln_time,$pro;
        }
        my $ln_time=join ",",@ln_time;

        my @ln_ances;
        for my $j(sort {$a<=>$b} keys %ances)
        {
            my $pro=sprintf "%.3f",$ances{$j}/$sum;
            push @ln_ances,$pro;
        }
        my $ln_ances=join ",",@ln_ances;
    
        my $ln=join "|",@b;

        print OUT "$a[0]\t$a[1]\t$a[2]\t$hap\t$ln_time\t$ln_ances\t$ln\n";       
    }
}
close IN;
close OUT;
