#!/bin/bash

# for each sample with ≥10x coverage sequencing

samtools view --threads 5 -q 20 -F 3332 -b sort.bam | samtools depth --threads 5 - | gzip > raw.depth.gz

perl depth_to_BED.pl raw.depth.gz depth.bed.gz

zcat depth.bed.gz | awk '{if($4>=2 && $4<=50) print $1"\t"$2"\t"$3}' | gzip > depth.filter.bed.gz

perl merge_adjacent.pl depth.filter.bed.gz depth.filter.merge.gz

rm raw.depth.gz depth.bed.gz depth.filter.bed.gz 

perl file_split.pl -L chr.txt -I depth.filter.merge.gz
