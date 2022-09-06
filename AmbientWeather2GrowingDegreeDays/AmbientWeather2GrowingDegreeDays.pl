#!/usr/bin/perl
#
# Assumptions:
# This tool reads a CSV exported from the AmbientWeather dashboard's data 
# interface.  The data should be at least in the format of DataElement,Date,Value
# where we assume that the first element will be a low or high temperature, the 
# second will be the date for that element, and the third will be the actual value.

use strict;

# coalesce the data we want from the csv (stdin)
my @csv;
while(<>){
	my $l = $_;
	chomp; 

	# Only care about high and low temps
	if(/^(High,|Low,)/) {
		push @csv,$l;
	}
}

# Process those rows to extract the high and low temps
my %d; 
foreach (@csv) {
	my @p=split/,/;
	$d{$p[1]}{Low} = $p[2] if $p[0] eq 'Low';
	$d{$p[1]}{High}=$p[2] if $p[0] eq 'High';
}

# total growing degree days accumulator
my $total_gdd=0;

# Header for our output
print "Date, Date's GDD, Cumulative GDD\n";

# Process the data to extract the average temperature for the date, and
# calculate the growing degrees days for the date; add it to the accumulator
foreach (sort keys %d){ 
	my $avg = ($d{$_}{High}>86?86:$d{$_}{High} + $d{$_}{Low})/2; 
	my $gdd = $avg-50.0; $gdd = 0 if $gdd < 0; 
	$total_gdd += $gdd;
	print "$_, $gdd, $total_gdd\n";
}

# And report total amount
print "Total Grow Degree Days: $total_gdd\n";
