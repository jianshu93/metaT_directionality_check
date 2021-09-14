#!/usr/bin/perl


use warnings;


# Author: Eric Johnston
# Date: 05/17/2018


open(IN1,$ARGV[0]);

my %hash_FW;
my %hash_RV;
my %hash_gene;
my %hash_sample;
my $sample_ID;
while(<IN1>){
chomp;
  @col=split("\t",$_);
  ($sample_ID) = $col[0] =~ m/^(.+?)_/;
  $hash_gene{$col[1]}=1;
  $hash_sample{$sample_ID}=1;
  if ($col[8] < $col[9]) {
$hash_FW{$sample_ID.__.$col[1]}++;
} elsif ($col[8] > $col[9]) {
$hash_RV{$sample_ID.__.$col[1]}++;
}
}
for my $keys_sample0 (keys %hash_sample) {
print "\t".$keys_sample0.".FW";
}
for my $keys_sample0 (keys %hash_sample) {
print "\t".$keys_sample0.".RV";
}
print "\n";


for my $keys_gene (keys %hash_gene) {
print $keys_gene;
for my $keys_sample (keys %hash_sample) {
if (exists $hash_FW{$keys_sample.__.$keys_gene}) {
print "\t",$hash_FW{$keys_sample.__.$keys_gene};
} else {
print "\t0";
}
}
for my $keys_sample (keys %hash_sample) {

if (exists $hash_RV{$keys_sample.__.$keys_gene}) {
print "\t",$hash_RV{$keys_sample.__.$keys_gene};
} else {
print "\t0";
}
}
print "\n";
}

close(IN1);
