#!/usr/bin/env perl

#-- Part of squeezeM distribution. 01/05/2018 Original version, (c) Javier Tamames, CNB-CSIC
#-- Needed to create LCA database. Joins taxonomy with nr entries. Creates taxid_tree.txt file

#-- Input/Output files

my $lca_dir=$ARGV[0];
die if(!$lca_dir);

my $inputfile="$lca_dir/nr.taxlist.db";	#-- From nrindex.pl, identification entries -> species
my $taxatreefile="$lca_dir/taxatree.txt";	#-- From rectaxa.pl, full taxonomy

my $outfile="$lca_dir/taxid_tree.txt";

my @ranks=('superkingdom','phylum','class','order','family','genus','species');
open(infile1,$taxatreefile) || die "Cannot open $taxatreefile\n";
while(<infile1>) {
	chomp;
	next if !$_;
	my @k=split(/\;/,$_);
	my @f=split(/\:/,$k[0]);
	for(my $pos=0; $pos<=$#k; $pos++) {
		my @f=split(/\:/,$k[$pos]);
		my $specie=$f[2];
		for(my $pos2=$pos+1; $pos2<=$#k; $pos2++) {
			@p=split(/\:/,$k[$pos2]);
			$tax{$specie}{$p[0]}=$p[2];
			# print "$specie\t$pos\t$k[$pos]\t$p[0]\t$p[2]\n";
			}
		}
	}
close infile1;

open(outfile1,">$outfile") || die "Cannot open output file $outfile\n";
open(infile2,$inputfile) || die;
my %store;
while(<infile2>) {
	chomp;
	next if !$_;
	%store=();
	my ($id,$tax)=split(/\t/,$_);
	print outfile1 "$id";
	# print "*$id\t*$acc\t*$tax\n";
	my @k=split(/\;/,$tax);
	foreach my $l(@k) {
		$store{'species'}{$l}++;
		foreach my $rk(@ranks) {
			my $corresp=$tax{$l}{$rk};
			# print "$l -> $rk -> $corresp\n";
			next if(!$corresp);
			$store{$rk}{$corresp}++; 
		}
	}
	foreach my $rk(reverse @ranks) {
		my @listtax=sort keys %{ $store{$rk} };
		my $string=join(";",@listtax);
		print outfile1 "\t$string";
		}
	print outfile1 "\n";				
	}
	
close infile2;
close outfile1;

print "File created: $outfile\n";
