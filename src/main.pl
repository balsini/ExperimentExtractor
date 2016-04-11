#!/usr/bin/perl

use warnings;
use strict;
use File::Slurp qw(read_dir);

my $base_path = '/home/alessio/git/rtlib2.0/build/examples/accelerated_full/results/';
my $filename = 'output.txt';

my @runs = sort { -M "$base_path/$a" <=> -M "$base_path/$b" } grep { -d "$base_path/$_" } read_dir($base_path);
my $root = $base_path . $runs[0]; 

sub deadline_miss_file
{
	my $relative_RT_column = 3;
	my $fh = $_[0];
	
	while (my $row = <$fh>) {
			  
		# Remove comments
		my $comment_start = index($row, '#'); 
		$row = substr($row, 0, $comment_start);
			  
		my @columns = split /\s+/, $row;
		
		
		if (scalar(@columns) ge 1 &&
		scalar(@columns) le $relative_RT_column ) {
			print 'here';
		}
		
		if (scalar(@columns) gt $relative_RT_column) {
			
			if ($columns[$relative_RT_column] gt '1.0') {
				return 1;
			}
			
		}
	}
	return 0;
}


# For each experiment 
for my $experiment (sort { $a cmp $b } grep { -d "$root/$_" } read_dir($root)) {
    print "$experiment\t SchedulableTasksets\n";
    
    my $experiment_root = $root . '/' . $experiment;
    
    # For each experiment parameter
    for my $x (sort { $a cmp $b } grep { -d "$experiment_root/$_" } read_dir($experiment_root)) {
    	#print "\tx: $x\n";
    	print "$x\t";
    	
    	my $result_root = $experiment_root . '/' . $x;
    	
    	# For each result
    	my $dlm = 0;
    	my $samples = 0;
    	for my $result (sort { $a cmp $b } grep { -d "$result_root/$_" } read_dir($result_root)) {
	    	
	    	my $file_path = $result_root . '/' . $result . '/' .$filename;
			open(my $fh, '<:encoding(UTF-8)', $file_path)
			  or die "Could not open file '$file_path' $!";
			  
			$dlm = $dlm + deadline_miss_file($fh);
			$samples = $samples + 1;
	    }
	    my $succeeded = ($samples - $dlm) / $samples;
	    print "$succeeded\n";
    }
}
