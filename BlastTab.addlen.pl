#!/usr/bin/perl -w

# Author: Jianshu Zhao
# Date: 08/23/2021

use strict;
use Getopt::Long;

#getopts files
my $fasta_file;
my $blast_file;
my $out_file="output.blast.length";
my $help=0;
my $pMatch_param;
my $qLength_param;

#global variables
my %fasta_dictionary;
my @new_blast_lines;
my $fasta_seq_count=0;
my $total_length=0;
my $num_blast=0;
my $num_kept=0;
my $num_dropped=0;

sub initialize {
  GetOptions(
  'i=s' => \$fasta_file,
  'b=s' => \$blast_file,
  'o=s' => \$out_file,
  'm=i' => \$pMatch_param,
  'l=i' => \$qLength_param,
  'h' => \$help,
  ) or die "Incorrect usage!\n";

  #check for help
  if ($help ne 0) {usage(); exit 1;}
  #check for input files
  unless (defined $fasta_file || defined $blast_file) {
    print "You need to enter all input files\n";
    usage(); exit 1;
  }
  unless (defined $pMatch_param) {
    $pMatch_param = 95;
  }
  unless (defined $qLength_param) {
    $qLength_param = 50;
  }
}

sub usage{
  print "\nHow to run this code:\n";
  print "\n./BlastTab.addlen.pl -i fasta_file -b blast_file -o output_name -m percent match cutoff -l query length cutoff\n";
  print "The fasta file are the sequences that are being mapped to the subject [query]\n";
  print "The blast must be in tabular blast format\n";
  print "The output will be in tabular blast format with the length of each sequence added\n";
}


sub Readfasta {
  my ($fasta) = @_;
  open (FILE, "<", $fasta) or die "Can't open the file $fasta!!\n";
  my $line; #tmp line variable
  my $k=0; #tmp variable to determine what to look for in a file
  my $id; #store id
  my $length; #store length
  while (<FILE>) {
    $line = $_;
    chomp $line;
    if ($line =~ m/^>/ && $k == 0) {
      $line =~ s/>//g; #get rid of the '>'
      #$line =~ s/\s*//g; #get rid of spaces
      my @values = split(' ', $line);
      $id = $values[0];
      $k=1; #set this so next time we get the sequence
      $fasta_seq_count++;
    }
    elsif ($k == 1) {
      $line =~ s/\s*//g; #get rid of spaces
      $length = length $line;
      $total_length += $length;
      $fasta_dictionary{$id} = $length;
      $k=0;
    }
  }
  close FILE;
}

sub Addlen {
  open (BLAST, "<", $blast_file) or die "Can't open blast file!!\n";
  open (OUT, ">", $out_file) or die "Can't open the output file!!\n";
  my $line; my @values; #variable to store split file
  my $query; my $qLength; my $aLength; my $pMatch; #variables from the blast output
  my $newline; my $array_length; #values for making output line
  while (<BLAST>) {
    #get the values
    $line = $_;
    chomp $line;
    @values = split('\t', $line);
    $query = $values[0];
    $qLength = $fasta_dictionary{$query};
    $aLength = $values[3];
    $pMatch = ($aLength / $qLength) * 100;
    $num_blast++;
    #corrected identity is the (alignment length / query length ) * percent identity
    my $corrected_identity = ($aLength / $qLength) * $values[2];

    #calculations
    if ($corrected_identity >= 50) {
#    if ($pMatch >= $pMatch_param && $qLength >= $qLength_param) {
      $num_kept++;
      $array_length = scalar @values;
      for (my $i=0; $i < $array_length; $i++) {
        print OUT $values[$i], "\t"; #print out the blast line
      }
      print OUT $qLength, "\t", $pMatch, "\n"; #adding the new values
    }
    else {
      $num_dropped++;
    }
  }
  close BLAST;
  close OUT;
}

initialize();
print "Running script BlastTab.addlen.pl -i $fasta_file -b $blast_file -o $out_file\n";
Readfasta($fasta_file);
my $avg = $total_length / $fasta_seq_count;
print "The total number of fasta sequences is $fasta_seq_count\n";
print "The average sequence lenth is $avg\n";
Addlen();
print "The total number of blast hits is $num_blast\n";
print "Blast hits above 50 bp query and above 90% match: $num_kept\n";
print "Blast hits that did not pass filter: $num_dropped\n";
