#!/bin/bash

# here is an example to normalize the snp number in pairwise samples.

# sample.info is a sample list
# "1.sdiff.summary" is the snp number by plink2 in "03.snp_number_calculation"
# "1.p.ECR" is the intersection of effective covered region in pairwise samples in "02.intersection_of_ECR"
# the distance will be normizaled to SNP number per Mb, which could be used as the input of IntroBlocker

perl dis_square.pl sample.info 1.sdiff.summary 1.raw_dist; perl 1Mb_dis_square.pl 1.p.ECR 1.raw_dist 1.dist.txt 

perl dis_square.pl sample.info 2.sdiff.summary 2.raw_dist; perl 1Mb_dis_square.pl 2.p.ECR 2.raw_dist 2.dist.txt

perl dis_square.pl sample.info 3.sdiff.summary 3.raw_dist; perl 1Mb_dis_square.pl 3.p.ECR 3.raw_dist 3.dist.txt

perl dis_square.pl sample.info 4.sdiff.summary 4.raw_dist; perl 1Mb_dis_square.pl 4.p.ECR 4.raw_dist 4.dist.txt

perl dis_square.pl sample.info 5.sdiff.summary 5.raw_dist; perl 1Mb_dis_square.pl 5.p.ECR 5.raw_dist 5.dist.txt

perl dis_square.pl sample.info 6.sdiff.summary 6.raw_dist; perl 1Mb_dis_square.pl 6.p.ECR 6.raw_dist 6.dist.txt
