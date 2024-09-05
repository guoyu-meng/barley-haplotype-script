#!/bin/bash

# here is an example to calculate the intersection of effective covered region in pairwise samples. The window used here is 1Mb (shift: 200Kb).
# the 1,1000000 is the window interval. 
# the 500000 means the minimun effective covered region showed in the result, less than will be converted t missing. It can be set to 0 if you want to show all.
# the depth.list is the output of each sample in "01.effective_covered_region".
# the output x.s.ECR means the effective covered region of single sample; the output x.p.ECR means the effective covered region of pairwise sample

perl ECR_pairwise_sample.pl 1,1000000 depth.list 500000 1.s.ECR 1.p.ECR 
perl ECR_pairwise_sample.pl 200001,1200000 depth.list 500000 2.s.ECR 2.p.ECR 
perl ECR_pairwise_sample.pl 400001,1400000 depth.list 500000 3.s.ECR 3.p.ECR 
perl ECR_pairwise_sample.pl 600001,1600000 depth.list 500000 4.s.ECR 4.p.ECR 
perl ECR_pairwise_sample.pl 800001,1800000 depth.list 500000 5.s.ECR 5.p.ECR 
perl ECR_pairwise_sample.pl 1000001,2000000 depth.list 500000 6.s.ECR 6.p.ECR
