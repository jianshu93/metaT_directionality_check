### RNA seq DNA contamination check pipeline
This is for DNA contamination check when doing RNA sequencing (or metatranscriptomics).
directionality_check.pl is a perl script to see how many RNA reads are mapped to the gene strand of your DNA reference (typically your genome or assembly). Then if you sustract this value from total reads, you will have number of reads mapped to anti-sense, which is the reverse strand of gene strand. Note that the script expects a blast tabular output format. The query in the tabular should be either forward or reverse, but not both if you are doing pair-end sequencing. You may need to extract forward reads record or reverse reads record from the tabular output if you are using interleaved (R1,R2,R1.R2...) reads files as query for blastn. use -strand both for blastn!!

### How to use
```
## first of all, you need seqtk mergepe to prepare interleaved reads in fasta format. This is required

seqtk mergepe sample.R1.fasta.gz sample.R2.fasta.gz > sample.interleaved.fasta


Then run the pipeline.
./check_rna.sh database_genome query.fa output_dir

### if you have the filtered blast tabular output
perl directionality_check.pl tabular.txt > output.txt
```

### Comparison between directionality_check.pl and dirseq (https://github.com/wwood/dirseq) software developed by Ben. Woodcroft.

This is a comparison using the NTO RNA seq dataset (manuscript in preparation). You need to remove ribosomal RNA reads first and then run blastn to have the tabular output as explained above (95% query alignment ratio and 98% identity). For those samples, if the reads mapped to anti-sense ratio is far below 50%, then you can be confident that you are actually sequencing RNA reads but not DNA. If reads mapped to anti-sense ratio is very close 50%, then you probably have DNA contamination during RNA sequencing. That being said, S14, S17,S18, S19, S20, S21 are contaminated RNA sequencing by DNA. Other samples look nice.


![dirseq_all_new](https://user-images.githubusercontent.com/38149286/133333611-63f681e2-8efa-44ac-880c-0c28ab5da360.jpg)


### Reference

1. Ben J Woodcroft et al. 2018. “Genome-Centric View of Carbon Processing in Thawing Permafrost.” 560(7716):1–24.
2. Johnston, Eric R. et al. 2019. “Phosphate Addition Increases Tropical Forest Soil Respiration Primarily by Deconstraining Microbial Population Growth.” Soil Biology and Biochemistry 130:43–54.
