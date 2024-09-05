=pod

The perl is to calculate the contribution from a certain wild ancestry in different times. The contribution of each wild ancestry were  normalized to 100% percentage

(1) admix_pro: only wild barley with individual ancestry >= admix_pro (e.g. 0.85) were used 

(2) region: R1: distal; R2: interstitial; C: proximal (or pericentromeric), all (entire genome)

(3) fre : output file of recent_gene_flow_filter.pl

(4) output: contribution of each wild ancestry in 5 times 

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV !=4;

my $admix_pro=shift; # 0.85
my $region=shift;
my $fre=shift; # raw grp
my $output=shift;

my %r;
if ($region eq 'R1'){$r{R1}=1}
elsif ($region eq 'R2'){$r{R2}=1}
elsif ($region eq 'Cen'){$r{Cen}=1}
elsif ($region eq 'all'){$r{R1}=1;$r{R2}=1;$r{Cen}=1}
else{die $!}

my %x;
open IN,"gzip -dc $fre|" or die $!;
<IN>;
while (<IN>)
{
    chomp;
    my @a=split;
    next if not exists $r{$a[10]};

    if ($a[8]!=0 && $a[5]!=0) # WBDC_063:1,0,0,0,0,0:0,0.9557,0,0.0443,0|WBDC_308:1,0,0,0,0,0:0,0,1,0,0
    {
        next if $a[11] eq '0';
##########################################
# closest time
        my @b=split /,/,$a[11];
        my @t_index;
        for (my $i=0;$i<@b;$i++){push @t_index,$i if $b[$i] !=0}
        my $t_index=$t_index[-1];
#########################################
        my @c=split /\|/,$a[13];
        my %tem;
        my $test1=0;
        for my $el(@c)
        {
            my $time=(split /:/,$el)[1];
            my $ances=(split /:/,$el)[2];
            my @time=split /,/,$time;
            my @ances=split /,/,$ances;            

            my $i_time;
            for (my $i=0;$i<@time;$i++){$i_time=$i if $time[$i]==1}
            next if $i_time!=$t_index;

            my $test=0;
            my $i_ances;
            for (my $i=0;$i<@ances;$i++)
            {
                if ($ances[$i]>=$admix_pro){$i_ances=$i;$test++;last}
            }
            next if $test==0; 
            
            $test1++; 
            $tem{$i_ances}{$i_time}=1;
        }
########################################
# consider more samples
        next if $test1==0; # $test1==0 means no pure wild samples
        for my $num(1..$a[8])
        {
            for my $ances(sort {$a<=>$b} keys %tem)
            {
                for my $time(sort {$a<=>$b} keys %{$tem{$ances}}){$x{$ances}{$time}++}
            }
        }    
#########################################
    }
}
close IN;

open OUT,">$output";
for my $ances(sort {$a<=>$b} keys %x)
{
    my $total;
    for my $time(sort {$a<=>$b} keys %{$x{$ances}}){$total+=$x{$ances}{$time}}

    my @ln;
    for my $time(sort {$a<=>$b} keys %{$x{$ances}})
    {
        my $pro=$x{$ances}{$time}/$total;
        push @ln,$pro;
    }
    my $ln=join "\t",@ln;
    print OUT "ances$ances\t$ln\n";
}         
close OUT;
