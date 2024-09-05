=pod

(1) ADMIXTURE: ancestral information of each wild barley via ADMIXTURE

(2) grp_list: a list file of output of share_hap_step2.pl

(3) output:

22|WBDC_126:0,1,0,0,0:0.6315,0.2492,0.1194,0,0|WBDC_085:0,1,0,0,0:0.2678,0,0.0065,0.1182,0.6075

22 was the haplotype in 400.gz

WBDC_126:0,1,0,0,0:0.6315,0.2492,0.1194,0,0
WBDC_126: wild sample share the haplotype; the time (0,1,0,0,0) is in second (98 as threshold);the ADMIXTURE of WBDC_126 was 0.6315,0.2492,0.1194,0,0  

WBDC_085:another wild sample share the haplotype

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV !=3;

my $ADMIXTURE=shift; # ADMIXTURE result
my $grp_list=shift; # grp
my $output=shift;

my %x;
open IN,$ADMIXTURE or die $!;
while (<IN>)
{
    chomp;
    my @a=split;
    $x{$a[0]}="$a[1],$a[2],$a[3],$a[4],$a[5]";
}
close IN;

my @f;
open IN,$grp_list or die $!;
while (<IN>)
{
    chomp;
    push @f,$_;
}
close IN;

for my $f(@f)
{
    open IN,"gzip -dc $f|" or die $!;
    <IN>;
    while (<IN>)
    {
        chomp;
        my @a=split;
        for (my $i=3;$i<@a;$i++)
        {
            my @b=split /\|/,$a[$i];
            if ($b[1] ne '0')
            {
                my @c=split /,/,$b[1];
                for my $w_s(@c){$x{$a[1]}{$i}{$w_s}++}
            }
        }
    }
    close IN;
}

open IN,"gzip -dc $f[0]|" or die $!;
open OUT,"| gzip >$output";
my $t=<IN>;
print OUT "$t";
while (<IN>)
{
    chomp;
    my @a=split;
    for (my $i=3;$i<@a;$i++)
    {
        my @b=split /\|/,$a[$i];
        if ($b[1] ne '0')
        {
            my @c=split /,/,$b[1];
            my (%tem1,%tem2);
            for my $w_s(@c)
            {
                if ($x{$a[1]}{$i}{$w_s}==5)
                {
                    $tem1{$w_s}="$w_s:0,0,0,0,1:$x{$w_s}";
                    $tem2{$w_s}=6;
                }
                elsif ($x{$a[1]}{$i}{$w_s}==4)
                {
                    $tem1{$w_s}="$w_s:0,0,0,1,0:$x{$w_s}";
                    $tem2{$w_s}=5;
                }
                elsif ($x{$a[1]}{$i}{$w_s}==3)
                {
                    $tem1{$w_s}="$w_s:0,0,1,0,0:$x{$w_s}";
                    $tem2{$w_s}=4;
                }
                elsif ($x{$a[1]}{$i}{$w_s}==2)
                {
                    $tem1{$w_s}="$w_s:0,1,0,0,0:$x{$w_s}";
                    $tem2{$w_s}=3;
                }
                elsif ($x{$a[1]}{$i}{$w_s}==1)
                {
                    $tem1{$w_s}="$w_s:1,0,0,0,0:$x{$w_s}";
                    $tem2{$w_s}=2;
                }
                else{die $!}
            }
            my @share;
            for my $w_s(sort {$tem2{$a}<=>$tem2{$b}} keys %tem2){push @share,$tem1{$w_s}}
            my $share=join "|",@share;
            $a[$i]="$b[0]|$share";
        }
    }
    my $ln=join "\t",@a ;
    print OUT "$ln\n";  
}
close IN;
close OUT;
