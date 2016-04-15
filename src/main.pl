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
	my $relative_RT_column_HW = 3;
	my $relative_RT_column_SW = 6;
	my $fh = $_[0];
	
	my $SW_miss = 0;
	my $HW_miss = 0;
	
	while (my $row = <$fh>) {
			  
		# Remove comments
		my $comment_start = index($row, '#'); 
		$row = substr($row, 0, $comment_start);
			  
		my @columns = split /\s+/, $row;
		
		
		if (scalar(@columns) ge 1 &&
			(scalar(@columns) le $relative_RT_column_SW || scalar(@columns) le $relative_RT_column_HW)) {
			print 'here';
		}
		
		if (scalar(@columns) gt $relative_RT_column_HW && scalar(@columns) gt $relative_RT_column_SW) {
			
			if ($columns[$relative_RT_column_SW] gt '1.0') {
				$SW_miss = 1;
			}
			if ($columns[$relative_RT_column_HW] gt '1.0') {
				$HW_miss = 1;
			}
			
		}
	}
	return ($HW_miss, $SW_miss);
}


# For each experiment 
for my $experiment (sort { $a cmp $b } grep { -d "$root/$_" } read_dir($root)) {
    print "$experiment\tSchedulableTasksetsHW\tSchedulableTasksetsSW\n";
    
    my $experiment_root = $root . '/' . $experiment;
    
    # For each experiment parameter
    for my $x (sort { $a cmp $b } grep { -d "$experiment_root/$_" } read_dir($experiment_root)) {
    	#print "\tx: $x\n";
    	print "$x\t";
    	
    	my $result_root = $experiment_root . '/' . $x;
    	
    	# For each result
    	my $dlmHW = 0;
    	my $dlmSW = 0;
    	my $samples = 0;
    	for my $result (sort { $a cmp $b } grep { -d "$result_root/$_" } read_dir($result_root)) {
	    	
	    	my $file_path = $result_root . '/' . $result . '/' .$filename;
			open(my $fh, '<:encoding(UTF-8)', $file_path)
			  or die "Could not open file '$file_path' $!";
			  
			my @dl_miss = deadline_miss_file($fh);
			$dlmHW = $dlmHW + $dl_miss[0];
			$dlmSW = $dlmSW + $dl_miss[1];
			$samples = $samples + 1;
	    }
	    my $succeededHW = ($samples - $dlmHW) / $samples;
	    my $succeededSW = ($samples - $dlmSW) / $samples;
	    print "$succeededHW\t$succeededSW\n";
    }
}
