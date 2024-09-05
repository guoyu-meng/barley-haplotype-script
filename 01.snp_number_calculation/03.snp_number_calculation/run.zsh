#!/bin/bash

# here is an example to calculate the SNP number in pairwise samples. The window used here is 1Mb (shift: 200Kb).

plink2 --bfile chr1H --allow-extra-chr --out 1 --chr chr1H --from-bp 1 --to-bp 1000000 --sample-diff counts-only counts-cols=ibs0,ibs1 ids=sample1 sample2 sample3 sample4 sample5

plink2 --bfile chr1H --allow-extra-chr --out 2 --chr chr1H --from-bp 200001 --to-bp 1200000 --sample-diff counts-only counts-cols=ibs0,ibs1 ids=sample1 sample2 sample3 sample4 sample5

plink2 --bfile chr1H --allow-extra-chr --out 3 --chr chr1H --from-bp 400001 --to-bp 1400000 --sample-diff counts-only counts-cols=ibs0,ibs1 ids=sample1 sample2 sample3 sample4 sample5

plink2 --bfile chr1H --allow-extra-chr --out 4 --chr chr1H --from-bp 600001 --to-bp 1600000 --sample-diff counts-only counts-cols=ibs0,ibs1 ids=sample1 sample2 sample3 sample4 sample5

plink2 --bfile chr1H --allow-extra-chr --out 5 --chr chr1H --from-bp 800001 --to-bp 1800000 --sample-diff counts-only counts-cols=ibs0,ibs1 ids=sample1 sample2 sample3 sample4 sample5

plink2 --bfile chr1H --allow-extra-chr --out 6 --chr chr1H --from-bp 1000001 --to-bp 2000000 --sample-diff counts-only counts-cols=ibs0,ibs1 ids=sample1 sample2 sample3 sample4 sample5
