
perl ../keep.pl wild.list ../../00.format/example/chr1H.group.gz chr1H.group.wild.gz

perl ../theta-w.pl chr1H.group.wild.gz 0.2 theta-w.wild.txt

perl ../shannon_index.pl chr1H.group.wild.gz 0.2 shannon_index.wild.txt 
