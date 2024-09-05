
# same as 03.statistics_of_haplotype_matrix/00.format/example 

perl ../../../03.statistics_of_haplotype_matrix/00.format/allele_fre.pl pop.order pop.info ../../data/400.gz fre.gz

perl ../../../03.statistics_of_haplotype_matrix/00.format/allele_fre.mark_region.pl chr1H.region fre.gz fre.region.gz
