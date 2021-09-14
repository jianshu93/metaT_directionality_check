This is for DNA contamination check when doing RNA sequencing (or metatranscriptomics).
directionality_check.pl is a perl script to see how man RNA reads are mapped to the DNA reference (typically your genome or assembly). Note that the script expects that you have a blast tabular output format. The query should be either forward or reverse, but not both if you are doing pair-end sequencing. You may need to extract forward reads record or reverse reads record from the tabular output if you are using interleaved (R1,R2,R1.R2...) reads files as query for blastn.

### Comparison between directionality_check.pl and dirseq software developed by Ben. Woodcroft.

