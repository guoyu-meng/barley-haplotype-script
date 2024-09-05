# the perl is to find the ECR in pairwise samples

#!/usr/bin/perl -w
use strict;
use warnings;

die '@ARGV is required' if @ARGV != 5;

my $region=shift; # 10000,20000 window interval
my $depth_file_list=shift; # a list file including 2 columns: sample_name depth_file path
my $threhold=shift; # if ECR < threhold, show 0 (missing) in the pairwise ECR. set threhold = 0 if want to show all  
my $output1=shift; # ECR for single sample
my $output2=shift; # ECR for pairwise sample

my $st=(split /,/,$region)[0];
my $end=(split /,/,$region)[1];

my (@s,%x,%s_ECR);
open IN,$depth_file_list or die $!;
open OUT,">$output1";
while (<IN>)
{
    chomp;
    my @a=split;
    push @s,$a[0];
    my $total=0;
    open IN1,"gzip -dc $a[1]|" or die $!;
    while (my $ln=<IN1>)
    {
        chomp $ln;
        my @ln=split /\s+/,$ln;
        next if $ln[2]<$st;
        last if $ln[1]>$end;
        if ($ln[1]<$st && $ln[2]>$st){$ln[1]=$st}
        if ($ln[1]<$end && $ln[2]>$end){$ln[2]=$end}
        push @{$x{$a[0]}},"$ln[1]-$ln[2]";
        $total+=$ln[2]-$ln[1]+1;
    }
    close IN1;
    $s_ECR{$a[0]}=$total;
    print OUT "$total\n";
}
close IN;
close OUT;

my %y;
for (my $i=0;$i<@s;$i++)
{
    for (my $m=0;$m<@s;$m++)
    {    
        if ($s_ECR{$s[$i]}>=$threhold && $s_ECR{$s[$m]}>=$threhold)
        {
            if ($m>$i)
            {               
                my @a=@{$x{$s[$i]}};
                my @b=@{$x{$s[$m]}};
                my $res=intersect (\@a,\@b);
                my $ovarlap=0;
                if ($res)
                {
                    my @tem=split /\t/,$res;
                    for my $el(@tem)
                    {
                        my @region=split /-/,$el;
                        $ovarlap+=$region[1]-$region[0]+1;
                    }
                } 
                $y{$i}{$m}=$ovarlap;
                $y{$m}{$i}=$ovarlap;
            }
            elsif ($m==$i)
            {
                $y{$i}{$m}=$s_ECR{$s[$i]};
                $y{$m}{$i}=$s_ECR{$s[$i]};
            }
        }
    }
}

open OUT,">$output2";
for (my $i=0;$i<@s;$i++)
{
    my @ln;
    for (my $m=0;$m<@s;$m++)
    {
        if (exists $y{$i}{$m}){push @ln,$y{$i}{$m}}
        else {push @ln,'0'}
    }
    my $ln=join "\t",@ln;
    print OUT "$ln\n";  
}
close OUT;

sub max
{
    if ($_[0]>=$_[1]){return $_[0]}
    else {return $_[1]}
}

sub min
{
    if ($_[0]>=$_[1]){return $_[1]}
    else {return $_[0]}
}

sub intersect
{
    my ($ar1,$ar2)=@_;

    my $i=0;
    my $j=0;

    my @ln;
    while ($i<@$ar1 && $j<@$ar2)
    {
        my $a1=(split /-/,$$ar1[$i])[0];
        my $a2=(split /-/,$$ar1[$i])[1];
        my $b1=(split /-/,$$ar2[$j])[0];
        my $b2=(split /-/,$$ar2[$j])[1];

        if ($b2>=$a1 && $a2>=$b1)
        {
            my $st=max($a1,$b1);
            my $end=min($a2,$b2);
            push @ln,"$st-$end";
        }

        if ($b2==$a2){$i++;$j++}
        elsif ($b2<$a2){$j++}
        else{$i++}
    }
    my $ln=join "\t",@ln;
    return "$ln";
}            
