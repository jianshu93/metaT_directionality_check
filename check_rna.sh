#!/bin/bash

# author: Jianshu Zhao (jianshu.zhao@gatech.edu)
# Date: 09/10/2021

#checks for usage
if [[ "$1" == "" || "$1" == "-h" || "$2" == "" || "$3" == "" ]]
then
  echo "
  Usage: ./check_rna.sh database_genome query.fa output_dir

  database_genome      directory with genome files as reference (will be used to generate gene file by prodigal or MetaGeneMark in nt format)
  query.fa      quality controlled and ribosomal RNA free RNA seq fasta file that will be mapped to the database [most likely your RNA seq reads, interleaved reads in fasta format is expected]
  output_dir    directory for the blast output and contamination values
                blast output:         final.blst [Unique matches with over 95% coverage and 98% identity]
                contamination output:     contamination_report.txt
  " >&2
  exit 1
fi

#stores file names
database=$1
reads=$2
output=$3

if ! command -v blastn &> /dev/null
then
    echo "blastn could not be found, please install it via conda or from source"
    exit
fi

if [ -d "$output" ] 
then
    echo "Directory $output already exists. MAKE SURE you want to do this"
else
    echo "making directory $output ..."
    $(mkdir $output)
fi

if [ -d "$database" ]; then
    echo "$database exists"
    dfiles="${database}/*.fasta"
    for F in $dfiles; do
	      BASE=${F##*/}
	      SAMPLE=${BASE%.*}
        $(./dependencies/seqtk_linux rename $F ${SAMPLE}. > $output/${SAMPLE}.rename.fasta)
        $(./pprodigal -i $output/${SAMPLE}.rename.fasta -f gff -d $output/${SAMPLE}.fna -o $output/${SAMPLE}.gff -p meta -T 8)
        $(./dependencies/seqtk_linux seq -C $output/${SAMPLE}.fna > $output/${SAMPLE}.fa)
        $(cat $output/${SAMPLE}.fa >> $output/all_gene_rename.fa)
    done
else
    echo "input directory does not exist, please offer a directory that exists (must ends with fasta files)"
    exit 1
fi

database_all=$output/all_gene_rename.fa
#variables
BLAST=0


#Reformat fastas
if [[ -s $output/all_gene_rename.reformatted ]]
then
  database_all=$output/all_gene_rename.reformatted
else
  #check if file needs it
  num_lines=$(wc -l $output/all_gene_rename.fa | head -n1 | awk '{print $1;}')
  num_headers=$(grep ">" $output/all_gene_rename.fa | wc -l)
  num_headers=$((num_headers * 2))
  if [[ $num_headers -eq $num_lines ]]
  then
    echo "The $database genome file is in correct format..."
  else
    #reformat the fasta and rename the variable
    echo "Reformatting the $database file so seqs are on one line..."
    ./FastA.reformat.oneline.pl -i $output/all_gene_rename.fa -o $output/all_gene_rename.reformatted
    echo "Done reformatting $database..."
    database_all=$output/all_gene_rename.reformatted
  fi
fi

if [[ -s $output/reads.reformatted ]]
then
  reads=$output/reads.reformatted
else
  #Check reformatting the other file
  num_lines=$(wc -l $reads | head -n1 | awk '{print $1;}')
  num_headers=$(grep ">" $reads | wc -l)
  num_headers=$((num_headers * 2))
  if [[ $num_headers -eq $num_lines ]]
  then
    echo "The $reads file is in correct format..."
  else
    #reformat the fasta and rename the variable
    echo "Reformatting the $reads file so seqs are on one line..."
    ./FastA.reformat.oneline.pl -i $reads -o $output/reads.reformatted
    echo "Done reformatting $reads..."
    reads=$output/reads.reformatted
  fi

fi
echo "add tag to reads header and reformat interleaved file..."

if [[ -s $output/reads.reformatted.new ]]
then
  reads=$output/reads.reformatted.new
else
  $(awk 'NR%4==1{c=2} c&&c--' $reads > $output/reads.reformatted_1)
  $(awk 'NR%4==3{c=2} c&&c--' $reads > $output/reads.reformatted_2)
  reads_1=$output/reads.reformatted_1
  reads_2=$output/reads.reformatted_2
  $(./FastA.tag.rb -i $reads_1 -o $output/reads.reformatted_1.rename -s /1 -q -p non-ribosomal_)
  $(./FastA.tag.rb -i $reads_2 -o $output/reads.reformatted_2.rename -s /2 -q -p non-ribosomal_)
  $(./dependencies/seqtk_linux mergepe $output/reads.reformatted_1.rename $output/reads.reformatted_2.rename > $output/reads.reformatted.new)
  $(rm $output/reads.reformatted_1 $output/reads.reformatted_2 $output/reads.reformatted_1.rename $output/reads.reformatted_2.rename)
  reads=$output/reads.reformatted.new
fi
echo "reformat interleaved file done"

#Check to see if the final blast file is present
if [[ -s $output/final.blst ]]
then
  echo "Final blast file found in the output directory you provided. Not running blast again or filtering..."
  echo "Now running recruitment plot scripts..."
  BLAST=1
else
  #Run blast
  echo "Making BLAST database..."
  makeblastdb -in $database_all -dbtype nucl
  echo "Running BLAST with 98% identity cutoff..."
  blastn -db $database_all -query $reads -out $output/tmp.orig.blst -task megablast -evalue 1e-9 -perc_identity 98 -num_threads $(nproc) -mt_mode 1 -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen'
  echo "Done with BLAST..."
  #Filter for length
  echo "Adding length of query to blast result and filtering for 95% query alignment ratio and 50bp length filtering"
  ./BlastTab.addlen.pl -i $reads -b $output/tmp.orig.blst -o $output/tmp.length.blst
  #Filter for best match
  echo "Only keeping best match from BLAST results..."
  ./BlastTab.besthit.pl -b $output/tmp.length.blst -o $output/final.blst
fi
if [[ $BLAST -eq 0 ]]
then
  num_orig=$(wc -l $output/tmp.orig.blst | head -n1 | awk '{print $1;}')
  num_length=$(wc -l $output/tmp.length.blst | head -n1 | awk '{print $1;}')
  num_best=$(wc -l $output/final.blst | head -n1 | awk '{print $1;}')
  echo "
      Original number of blast hits:                            $num_orig
      Number of blast hits after filter for length of match:    $num_length
      Number of blast hits after filter for best match:         $num_best"

  #remove temporary files
  rm $output/tmp.orig.blst
  rm $output/tmp.length.blst
else
  num_best=$(wc -l $output/final.blst | head -n1 | awk '{print $1;}')
  echo "
    Number of blast hits:         $num_best"
fi

echo "Extracting forward and reverse reads from blast output..."
$(grep -E '*/1\t*' $output/final.blst > $output/final.1.blst)
$(grep -E '*/2\t*' $output/final.blst > $output/final.2.blst)
echo "Counting reads mapped to gene strand and reverse strand of gene strand"
./directionality_check.pl $output/final.1.blst > $output/final.check.1.txt
./directionality_check.pl $output/final.2.blst > $output/final.check.2.txt
$(tail -n +2 $output/final.check.1.txt | awk '{sum+=$2;sum2+=$3} END{printf sum;printf "\t";printf sum2;printf "\t";print sum2/(sum+sum2)}' > $output/contamination_report.1.txt)
$(tail -n +2 $output/final.check.2.txt | awk '{sum+=$2;sum2+=$3} END{printf sum2;printf "\t";printf sum;printf "\t";print sum/(sum+sum2)}' > $output/contamination_report.2.txt)
$(cat $output/contamination_report.1.txt $output/contamination_report.2.txt | awk '{sum+=$1;sum2+=$2} END{printf sum;printf "\t";printf sum2;printf "\t";print sum2/(sum+sum2)}' > $output/contamination_report.all.txt)
echo "Ratio of reads mapped to anti-sense is: " 
cat $output/contamination_report.all.txt | awk '{print $3}'
echo "All done"
