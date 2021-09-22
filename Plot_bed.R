if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("Sushi")

library(Sushi)
data(Sushi_ChIPSeq_pol2.bed)


colors = c("dodgerblue1","firebrick2","violet","yellow",
           "dodgerblue1","firebrick2","violet","yellow",
           "dodgerblue1","firebrick2","violet")

setwd("/Users/jianshuzhao/library/Mobile Documents/com~apple~CloudDocs/NTO")

### contaminated ATO samples
par(mfrow=c(2,1),mar=c(0,0,0,0))
s19.bed <- read.delim("S13.filtered.sorted.bed.contig48.forward.final.txt", header = FALSE,stringsAsFactors = FALSE)

head(s19.bed)
colnames(s19.bed) <- c("chrom", "start", "end", "name","score","strand")
head(s19.bed)

chrom            = "ATO_1_48"
chromstart      = 1
chromend         = 44028
plotBed(beddata= s19.bed,chrom = chrom,chromstart = chromstart,
chromend =chromend,colorby    = s19.bed$strand,
colorbycol = SushiColors(2),row  = "auto",wiggle=0.001,splitstrand=TRUE) 
labelgenome(chrom,chromstart,chromend,n=2,scale="Kb")
legend("topright",inset=0,legend=c("reverse","forward"),fill=SushiColors(2)(2),
       border=SushiColors(2)(2),text.font=2,cex=0.75)

head(Sushi_ChIPSeq_pol2.bed)

### plot gene

ATO_1_12.bed <- read.delim("ATO_1_48.bed.final", header = FALSE,stringsAsFactors = FALSE)
data(Sushi_genes.bed)

chrom            = "ATO_1_48"
chromstart       = 1
chromend         = 44028
chrom_biomart    = 15

head(ATO_1_12.bed)
colnames(ATO_1_12.bed) <- c("chrom", "start", "end", "name","score","strand")
head(ATO_1_12.bed)

plotGenes(ATO_1_12.bed,chrom,chromstart,chromend ,colorby=ATO_1_12.bed$strand,
          maxrows=1,height=0.01,colorbycol=colorRampPalette(c(rgb(red = 0, green = 0, blue = 1, alpha = 0.5), rgb(red = 1, green = 0, blue = 0, alpha = 0.5)),alpha=TRUE),plotgenetype="box",bentline=FALSE,
          labeloffset=1,fontsize=1.2,labeltext=FALSE,wigglefactor=0.000000000011)

labelgenome(chrom, chromstart,chromend,side=1,scipen=20,n=3,scale="Kb",line=.18,chromline=.5,scaleline=0.5)





