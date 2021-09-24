### RNA seq DNA contamination check pipeline
This is for DNA contamination check when doing RNA sequencing (or metatranscriptomics).
directionality_check.pl is a perl script to see how many RNA reads are mapped to the gene strand of your DNA reference (typically your genome or assembly). Then if you sustract this value from total reads, you will have number of reads mapped to anti-sense, which is the reverse strand of gene strand. Note that the script expects a blast tabular input format. You may need to extract forward reads record or reverse reads record from the tabular output if you are using interleaved (R1,R2,R1,R2...) reads files as query for blastn. use -strand both for blastn!! The mentioned steps are all done for you by the check_rna.sh script, together with a few other scripts developed by the kostas lab. For details, please contact Jianshu Zhao (jianshuzhao@yahoo.com)

### How to use
```
### for demo input, you must have wget and prodigal installed or in the path. Ruby, perl and Python 3 are also required.
git clone https://github.com/jianshu93/metaT_directionality_check.git
cd metaT_directionality_check
gunzip ./demo_input/INPUT_nonribosomal_S9.interleaved.subsample.fa.gz
unzip ./dependencies/*.zip
chmod a+x ./dependencies/*
chmod a+x ./*
./check_rna.sh ./demo_input/MAG ./demo_input/INPUT_nonribosomal_S9.interleaved.subsample.fa output

### for you own pair end metatranscriptomic reads
## first of all, you need seqtk mergepe to prepare interleaved reads in fasta format. This is required. other formats are not accecpted. Then run the pipeline.
seqtk mergepe sample.R1.fasta.gz sample.R2.fasta.gz > sample.interleaved.fasta
```
### output directory explained

You will have contamination_report.1.txt and contamination_report.2.txt, which showed you the numer of reads mapped to gene strand, reverse strand of gene strand (anti-sense) and ratio of reads mapped to anti-sense only for forward or reverse reads, respectively. contamination_report.all.txt is for both forward and reverse reads. The value (third column) should be very close for those 3 files. The last one will also be printed on screen


### Comparison between directionality_check.pl (this pipeline) and dirseq (https://github.com/wwood/dirseq) software developed by Ben. Woodcroft.

This is a comparison using the NTO RNA seq dataset (manuscript in preparation). You need to remove ribosomal RNA reads first and then run blastn to have the tabular output as explained above (95% query alignment ratio and 98% identity). For those samples, if the reads mapped to anti-sense ratio is far below 50%, then you can be confident that you are actually sequencing RNA reads but not DNA. If reads mapped to anti-sense ratio is very close 50%, then you probably have DNA contamination during RNA sequencing. That being said, S14, S17,S18, S19, S20, S21 are contaminated RNA sequencing by DNA. Other samples look nice.

![dirseq_all_new](https://user-images.githubusercontent.com/38149286/133333611-63f681e2-8efa-44ac-880c-0c28ab5da360.jpg)

### Detailed check of both good and contaminated samples
```
plot_bed.R
```


For each of the contig of reference assembly, we predicted genes for each assembly and then RNA reads were mapped to contigs (may be mapped to different strand of gene strand on the contig). Then we visualize how each RNA read was mapped to contig considering both start and stop positon and also strand of genes (each box in the bottom panel represent gene position and strand). The first figure is from S13 (good), as you can see a random chosen contig from the ATO assembly is also telling that most of the reads are mapped to gene strand instead of the reverse strand of gene strand. The second is from a contaminated sample S19. As you can see, most RNA reads are randomly mapped to both strand no matter where the genes are.

Both bam file and blastn based mapping tools, we have similar results. The last figure is from blastn while the former two are from bwa mem algorithm

![S13_ATO_1_48](https://user-images.githubusercontent.com/38149286/134280114-7e49c5ef-0523-48b1-9405-94b00a5b5af9.jpg)

![S19_ATO_1_48](https://user-images.githubusercontent.com/38149286/134280208-04aad47f-2b08-4b9f-a8e9-d858746ff93e.jpg)



### Reference

1. Ben J Woodcroft et al. 2018.Genome-Centric View of Carbon Processing in Thawing Permafrost. Nature 560(7716):1-24.
2. Johnston, Eric R. et al. 2019. Phosphate Addition Increases Tropical Forest Soil Respiration Primarily by Deconstraining Microbial Population Growth. Soil Biology and Biochemistry 130:43-54.
3. Zhu, Wenhan, Alexandre Lomsadze, and Mark Borodovsky. 2010. Ab Initio Gene Identification in Metagenomic Sequences. Nucleic Acids Research 38(12):e132-32.
4. Hyatt, Doug, Philip F. LoCascio, Loren J. Hauser, and Edward C. Uberbacher. 2012. Gene and Translation Initiation Site Prediction in Metagenomic Sequences. Bioinformatics 28(17):2223-30.
5. Rho, Mina, Haixu Tang, and Yuzhen Ye. 2010.FragGeneScan: Predicting Genes in Short and Error-Prone Reads. 38(20):e191.
6. Van der Jeugt, Felix, Peter Dawyndt, and Bart Mesuere. 2021. “FragGeneScanRs: Better and Faster Gene Prediction for Short Reads.” bioRxiv 1–7.
7. Phanstiel, Douglas H. 2014. “Sushi.R: Flexible, Quantitative and Integrative Genomic Visualizations for Publication-Quality Multi-Panel Figures.” Bioinformatics 1–3.
