=pod

The perl is to exclude the wild samples with pairwise IBS>=0.95. For each haplotype, only one wild barley accession were kept if ther were in a cluster of IBS>=0.95

(1) exclude_info:
in eac row, the IBS among wild barleys are >=0.95 

(2) grp: output of share_hap_step1.pl

(3) output: same format as share_hap_step1.pl 

=cut

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV !=3;

my $exclude_info=shift;
my $grp=shift; # raw grp
my $output=shift;

my @ex;
open IN,$exclude_info or die $!;
while (<IN>)
{
    chomp;
    my @a=split;
    my $ln=join "\t",@a;
    push @ex,$ln;
}
close IN;

open IN,"gzip -dc $grp |" or die $!;
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
            my $tem=&ex($b[1],@ex); #print "$tem\n";
            if ($tem ne 'N')
            {
                my @tem=split /\t/,$tem;

                my %ex;
                for my $el(@tem){$ex{$el}=1}
                
                my @g=split /,/,$b[1];
                my @new;
                for my $el(@g)
                {
                    push @new,$el if not exists $ex{$el};
                }
                my $new=join ",",@new;                                
                $a[$i]="$b[0]|$new";
            }
        }        
    }
    my $ln=join "\t",@a;
    print OUT "$ln\n"; 
}
close IN;
close OUT;

sub ex
{
    my @a=@_;
    my $w_s=shift @a;
    my @w_s=split /,/,$w_s; #print "@w_s\n";

    my @v;
    my $test=0;
    for my $el(@a)
    {
        my @cluster=split /\t/,$el; #print "@cluster\n";

        my %tem;
        for my $s(@w_s){$tem{$s}++}
        for my $s(@cluster){$tem{$s}++}

        my $num=0;
        for my $s(sort keys %tem){$num++ if $tem{$s}==2} #print "$num\n";
        if ($num>1)
        {
            $test++;
            my @new;
            for my $s(@w_s){push @new,$s if $tem{$s}==2}
            for (my $i=1;$i<@new;$i++){push @v,$new[$i]}
        }
    }
    if ($test==0){return "N"}
    else
    {
        my $v=join "\t",@v; #print "$v\n";
        return $v; 
    }
}
