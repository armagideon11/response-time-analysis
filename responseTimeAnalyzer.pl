#! usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $eventLog = $ARGV[0];
my $increment = $ARGV[1] || 60;
my $options = $ARGV[2] || "";
my $oneSecOut = "1secResponses.txt";
my $yellowOut = "yellowResponses.txt";
my $csvOut = "responseTimeAnalysis.csv";
open ELIN,"<",$eventLog or die $!;
if ($options eq "-r") {
	open REDOUT,">",$oneSecOut or die $!;
}
if ($options eq "-y") {
	open YELLOWOUT,">",$yellowOut or die $!;
}
if ($options eq "-x") {
	open CSVOUT,">",$csvOut or die $!;
}
my %response;
my $green_limit = 350;
my $yellow_limit = 1000;
my $max_ct_width = 0;
my $max_green_ct_width = 0;
my $max_yellow_ct_width = 0;
my $max_red_ct_width = 0;
my $total_ct_width = 0;
my $standard_out_width = 0;
my $max_avg_width = 0;
my $max_green_avg_width = 0;
my $max_yellow_avg_width = 0;
my $max_red_avg_width = 0;
my $total_avg_width = 0;
my $max_pct_width = 0;
my $max_green_pct_width = 0;
my $max_yellow_pct_width = 0;
my $max_red_pct_width = 0;
my $total_pct_width = 0;
my $starttime = localtime(time);
#$| = 1; # flush STDOUT after every print
while (my $eLLine = <ELIN>) {
	chomp $eLLine;
	my @eLArray = split(" ",$eLLine);
	my $timeStamp = substr($eLLine,index($eLLine,'['),22);
	my $hour =   (split(":",$timeStamp))[1];
	my $minute = (split(":",$timeStamp))[2];

	my $min_inc = int($minute/$increment)*$increment;
	if ($min_inc < 10) {
		$min_inc = "0".$min_inc;
	}
	
	my $ct_width = 0;
	my $green_ct_width = 0;
	my $yellow_ct_width = 0;
	my $red_ct_width = 0;
	my $responseTime = $eLArray[-1]*1000;
	if (!$response{'day'}{'response_sum'}) {
		$response{'day'}{'response_sum'} = 0.000;
	}
        if (!$response{$hour}{'response_sum'}) {
                $response{$hour}{'response_sum'} = 0.000;
        }
        if (!$response{$hour}{$min_inc}{'response_sum'}) {
                $response{$hour}{$min_inc}{'response_sum'} = 0.000;
        }

	$response{'day'}{'count'}++;
#	if ($response{'day'}{'count'}%1000 == 0) {
	#	print "$response{'day'}{'count'}\n";
#		print "* ";
#	}

	$response{'day'}{'response_sum'} = $response{'day'}{'response_sum'} + $responseTime;

	$response{$hour}{'count'}++;
	$ct_width = length($response{$hour}{'count'});
	$response{$hour}{'response_sum'} = $response{$hour}{'response_sum'} + $responseTime;
	$response{$hour}{$min_inc}{'count'}++;
        $response{$hour}{$min_inc}{'response_sum'} = $response{$hour}{$min_inc}{'response_sum'} + $responseTime;

	if ($responseTime <= $green_limit) {
		$response{'day'}{'green'}++;
	        if (!$response{'day'}{'green_sum'}) {
        	        $response{'day'}{'green_sum'} = 0.000;
        	}	
                $response{'day'}{'green_sum'} = $response{'day'}{'green_sum'} + $responseTime;

		$response{$hour}{'green'}++;
		$green_ct_width = length($response{$hour}{'green'}); 
 
	        if (!$response{$hour}{'green_sum'}) {
        	        $response{$hour}{'green_sum'} = 0.000;
        	}
		$response{$hour}{'green_sum'} = $response{$hour}{'green_sum'} + $responseTime;	

                $response{$hour}{$min_inc}{'green'}++;
                if (!$response{$hour}{$min_inc}{'green_sum'}) {
                        $response{$hour}{$min_inc}{'green_sum'} = 0.000;
                }
                $response{$hour}{$min_inc}{'green_sum'} = $response{$hour}{$min_inc}{'green_sum'} + $responseTime;

	} elsif ($responseTime > $green_limit && $responseTime <= $yellow_limit) {
                if ($options eq "-y") {
                        print YELLOWOUT "$eLLine\n";
		}
		$response{'day'}{'yellow'}++;
        	if (!$response{'day'}{'yellow_sum'}) {
                	$response{'day'}{'yellow_sum'} = 0.000;
        	}
                $response{'day'}{'yellow_sum'} = $response{'day'}{'yellow_sum'} + $responseTime;

                $response{$hour}{'yellow'}++;
		$yellow_ct_width = length($response{$hour}{'yellow'});

		if (!$response{$hour}{'yellow_sum'}) {
                	$response{$hour}{'yellow_sum'} = 0.000;
       		}                
		$response{$hour}{'yellow_sum'} = $response{$hour}{'yellow_sum'} + $responseTime;

                $response{$hour}{$min_inc}{'yellow'}++;
                if (!$response{$hour}{$min_inc}{'yellow_sum'}) {
                        $response{$hour}{$min_inc}{'yellow_sum'} = 0.000;
                }
                $response{$hour}{$min_inc}{'yellow_sum'} = $response{$hour}{$min_inc}{'yellow_sum'} + $responseTime;

	} else {

		if ($options eq "-r") {
			print REDOUT "$eLLine\n";
		}
		$response{'day'}{'red'}++;
        	if (!$response{'day'}{'red_sum'}) {
                	$response{'day'}{'red_sum'} = 0.000;
        	}                
		$response{'day'}{'red_sum'} = $response{'day'}{'red_sum'} + $responseTime;
                
		$response{$hour}{'red'}++;
		$red_ct_width = length($response{$hour}{'red'});

		if (!$response{$hour}{'red_sum'}) {
	                $response{$hour}{'red_sum'} = 0.000;
        	}
		$response{$hour}{'red_sum'} = $response{$hour}{'red_sum'} + $responseTime;

                $response{$hour}{$min_inc}{'red'}++;
                if (!$response{$hour}{$min_inc}{'red_sum'}) {
                        $response{$hour}{$min_inc}{'red_sum'} = 0.000;
                }
                $response{$hour}{$min_inc}{'red_sum'} = $response{$hour}{$min_inc}{'red_sum'} + $responseTime;

	}

	if ($ct_width > $max_ct_width) {
		$max_ct_width = $ct_width;
	}
	if ($green_ct_width > $max_green_ct_width) {
		$max_green_ct_width = $green_ct_width;
	}
        if ($yellow_ct_width > $max_yellow_ct_width) {
                $max_yellow_ct_width = $yellow_ct_width;
        }
        if ($red_ct_width > $max_red_ct_width) {
                $max_red_ct_width = $red_ct_width;
        }
}

if ($options eq "-y") {
	print "Events with over $green_limit milisecond response and less than $yellow_limit response output to $yellowOut\n\n"; 
	close (REDOUT);
}

if ($options eq "-r") {
        print "Events with over $yellow_limit milisecond response output to $oneSecOut\n\n";
        close (REDOUT);
}

 
foreach my $k (keys %response) {
	if ($response{$k}{'count'}) {
		$response{$k}{'average'} = $response{$k}{'response_sum'}/$response{$k}{'count'};
		$response{$k}{'percent'} = $response{$k}{'count'}/$response{'day'}{'count'};
	}
	if ($response{$k}{'green'}) {
		$response{$k}{'green_avg'} = $response{$k}{'green_sum'}/$response{$k}{'green'};
		$response{$k}{'green_pct'} = $response{$k}{'green'}/$response{$k}{'count'};
	}
	if ($response{$k}{'yellow'}) {
		$response{$k}{'yellow_avg'} = $response{$k}{'yellow_sum'}/$response{$k}{'yellow'};
		$response{$k}{'yellow_pct'} = $response{$k}{'yellow'}/$response{$k}{'count'};
	}
	if ($response{$k}{'red'}) {
		$response{$k}{'red_avg'} = $response{$k}{'red_sum'}/$response{$k}{'red'}; 
		$response{$k}{'red_pct'} = $response{$k}{'red'}/$response{$k}{'count'};
	}

	foreach my $h (keys %{$response{$k}}) {
		my %inc_hash;
		if ( UNIVERSAL::isa($response{$k}{$h},'HASH') ) {
			%inc_hash = %{$response{$k}};	
			if ($inc_hash{$h}{'count'}) {
        	        	$inc_hash{$h}{'average'} = $inc_hash{$h}{'response_sum'}/$inc_hash{$h}{'count'};
                		$inc_hash{$h}{'percent'} = $inc_hash{$h}{'count'}/$response{'day'}{'count'};
        		}
        		if ($inc_hash{$h}{'green'}) {
                		$inc_hash{$h}{'green_avg'} = $inc_hash{$h}{'green_sum'}/$inc_hash{$h}{'green'};
                		$inc_hash{$h}{'green_pct'} = $inc_hash{$h}{'green'}/$inc_hash{$h}{'count'};
        		}
        		if ($inc_hash{$h}{'yellow'}) {
                		$inc_hash{$h}{'yellow_avg'} = $inc_hash{$h}{'yellow_sum'}/$inc_hash{$h}{'yellow'};
                		$inc_hash{$h}{'yellow_pct'} = $inc_hash{$h}{'yellow'}/$inc_hash{$h}{'count'};
        		}
        		if ($inc_hash{$h}{'red'}) {
                		$inc_hash{$h}{'red_avg'} = $inc_hash{$h}{'red_sum'}/$inc_hash{$h}{'red'};
                		$inc_hash{$h}{'red_pct'} = $inc_hash{$h}{'red'}/$inc_hash{$h}{'count'};
        		}
		}
	}

	if ($k ne 'day') {
        	my $avg_width = length(sprintf '%.2f',$response{$k}{'average'});
                my $green_avg_width = 0;
		my $yellow_avg_width = 0;
		my $red_avg_width = 0;

                my $pct_width = length(sprintf '%.2f',$response{$k}{'percent'});
                my $green_pct_width = 0;
                my $yellow_pct_width = 0;
                my $red_pct_width = 0;

		if ($response{$k}{'green_avg'}) {
			$green_avg_width = length(sprintf '%.2f',$response{$k}{'green_avg'});
		}
		if ($response{$k}{'yellow_avg'}) {
			$yellow_avg_width = length(sprintf '%.2f',$response{$k}{'yellow_avg'});
		}
		if ($response{$k}{'red_avg'}) {
			$red_avg_width = length(sprintf '%.2f',$response{$k}{'red_avg'});
		}
		if ($avg_width > $max_avg_width) {
			$max_avg_width = $avg_width;
		}
                if ($green_avg_width > $max_green_avg_width) {
                        $max_green_avg_width = $green_avg_width;
                }
		if ($yellow_avg_width > $max_yellow_avg_width) {
                        $max_yellow_avg_width = $yellow_avg_width;
		}
                if ($red_avg_width > $max_red_avg_width) {
                        $max_red_avg_width = $red_avg_width;
 		}

                if ($response{$k}{'green_pct'}) {
                        $green_pct_width = length(sprintf '%.2f',$response{$k}{'green_pct'}*100);
                }
                if ($response{$k}{'yellow_pct'}) {
                        $yellow_pct_width = length(sprintf '%.2f',$response{$k}{'yellow_pct'}*100);
                }
                if ($response{$k}{'red_pct'}) {
                        $red_pct_width = length(sprintf '%.2f',$response{$k}{'red_pct'}*100);
                }
                if ($pct_width > $max_pct_width) {
                        $max_pct_width = $pct_width;
                }
                if ($green_pct_width > $max_green_pct_width) {
                        $max_green_pct_width = $green_pct_width;
                }
                if ($yellow_pct_width > $max_yellow_pct_width) {
                        $max_yellow_pct_width = $yellow_pct_width;
                }
                if ($red_pct_width > $max_red_pct_width) {
                        $max_red_pct_width = $red_pct_width;
                }	
	}
}

#my $clear = `clear`;
#print $clear;
print "File: $eventLog\n\n";
print "Total events analyzed: $response{'day'}{'count'}\n";
print "Average response time: ".sprintf '%.2f',$response{'day'}{'average'};
print "\n";
if ($response{'day'}{'green'}) {
	print "Green (<$green_limit ms): $response{'day'}{'green'}\n";
	print "\tAverage response time: ".sprintf '%.2f',$response{'day'}{'green_avg'};
	print "\n";
	print "\t%: ".sprintf '%.2f',($response{'day'}{'green_pct'}*100);
	print "\n";
}
if ($response{'day'}{'yellow'}) {
	print "Yellow ($green_limit ms - <= $yellow_limit ms): $response{'day'}{'yellow'}\n";
	print "\tAverage response time: ".sprintf '%.2f',$response{'day'}{'yellow_avg'};
	print "\n";
	print "\t%: ".sprintf '%.2f',($response{'day'}{'yellow_pct'}*100);
	print "\n";
}
if ($response{'day'}{'red'}) {
	print "Red (> $yellow_limit ms): $response{'day'}{'red'}\n";
	print "\tAverage response time: ".sprintf '%.2f',$response{'day'}{'red_avg'};
	print "\n";
	print "\t%: ".sprintf '%.2f',($response{'day'}{'red_pct'}*100);
	print "\n";
}
print "\n";

#my $commas13 = "," x 13;
my $commas = "," x 14;
if ($options eq "-x") {
	print CSVOUT "File: $eventLog$commas,\n";
	print CSVOUT "Total events analyzed: $response{'day'}{'count'}$commas,\n";
	print CSVOUT "Average response time: ".sprintf '%.2f',$response{'day'}{'average'};
	print CSVOUT "$commas,\n";
	if ($response{'day'}{'green'}) {
        	print CSVOUT "Green (<$green_limit ms): $response{'day'}{'green'}$commas,\n";
	        print CSVOUT ",Average response time: ".sprintf '%.2f',$response{'day'}{'green_avg'};
		print CSVOUT "$commas\n";
	        print CSVOUT ",%: ".sprintf '%.2f',($response{'day'}{'green_pct'}*100);
		print CSVOUT "$commas\n";
	}
	if ($response{'day'}{'yellow'}) {
	        print CSVOUT "Yellow ($green_limit ms - <= $yellow_limit ms): $response{'day'}{'yellow'}$commas,\n";
	        print CSVOUT ",Average response time: ".sprintf '%.2f',$response{'day'}{'yellow_avg'};
		print CSVOUT "$commas\n";
	        print CSVOUT ",%: ".sprintf '%.2f',($response{'day'}{'yellow_pct'}*100);
		print CSVOUT "$commas\n";
	}
	if ($response{'day'}{'red'}) {
	        print CSVOUT "Red (> $yellow_limit ms): $response{'day'}{'red'}$commas,\n";
	        print CSVOUT ",Average response time: ".sprintf '%.2f',$response{'day'}{'red_avg'};
		print CSVOUT "$commas\n";
	        print CSVOUT ",%: ".sprintf '%.2f',($response{'day'}{'red_pct'}*100);
		print CSVOUT "$commas\n";
	}
print CSVOUT "," x 16;
print CSVOUT "\n";
}

#print Dumper \%response;
$standard_out_width = $max_avg_width + $max_green_ct_width + $max_yellow_ct_width + $max_red_ct_width;
$total_ct_width = $max_ct_width + $max_green_ct_width + $max_yellow_ct_width + $max_red_ct_width;
$total_avg_width = $max_avg_width + $max_green_avg_width + $max_yellow_avg_width + $max_red_avg_width;
$total_pct_width = $max_pct_width + $max_green_pct_width + $max_yellow_pct_width + $max_red_pct_width;

if ($options eq "-v") {
	print "          Events (G,Y,R)";
	print " " x ($total_ct_width - 6);
	print "  ";
	print "Avg (G,Y,R)";
	print " " x ($total_avg_width - 3);
	print "  ";
	print "% (G,Y,R)";
	print "\n";
} else {
        print "          Avg (Count G,Y,R)\n";
}
print "-------+";
if ($options eq "-v") {
	print "-" x ($total_ct_width+9);
	print "+";
	print "-" x ($total_avg_width+9);
	print "+";
	print "-" x ($total_pct_width+9);
	print "+";
} else {
	print "-" x ($standard_out_width+9);
	print "+";
}
print "\n";

if ($options eq "-x") {
	print CSVOUT "," x 6;
	print CSVOUT "Green";
	print CSVOUT "," x 4;
	print CSVOUT "Yellow";
	print CSVOUT "," x 4;
	print CSVOUT "Red,\n";
	print CSVOUT ",Total,Avg,%,,Total,Avg,%,,Total,Avg,%,,Total,Avg,%\n";
}

foreach my $hour (sort keys %response) {
	my $hour_avg = sprintf '%.2f',$response{$hour}{'average'};
	my $hour_ct = $response{$hour}{'count'}; 
	my $hour_pct = sprintf '%.2f',($response{$hour}{'percent'}*100);
	my $hour_green = 0;
	my $hour_yellow = 0;
	my $hour_red = 0;
	my $hour_green_avg = "-";
	my $hour_yellow_avg = "-";
	my $hour_red_avg = "-";
	my $hour_green_pct = "-";
	my $hour_yellow_pct = "-";
	my $hour_red_pct = "-";

	if ($response{$hour}{'green'}) {
		$hour_green = $response{$hour}{'green'};
	}
	if ($response{$hour}{'yellow'}) {
		$hour_yellow = $response{$hour}{'yellow'};
	}
	if ($response{$hour}{'red'}) {
		$hour_red = $response{$hour}{'red'};
	}
        if ($response{$hour}{'green_avg'}) {
		$hour_green_avg = sprintf '%.2f',$response{$hour}{'green_avg'};
	}
        if ($response{$hour}{'yellow_avg'}) {
		$hour_yellow_avg = sprintf '%.2f',$response{$hour}{'yellow_avg'};
	}
        if ($response{$hour}{'red_avg'}) {
		$hour_red_avg = sprintf '%.2f',$response{$hour}{'red_avg'};
	}
        if ($response{$hour}{'green_pct'}) {
                $hour_green_pct = sprintf '%.2f',$response{$hour}{'green_pct'}*100;
        }
        if ($response{$hour}{'yellow_pct'}) {
                $hour_yellow_pct = sprintf '%.2f',$response{$hour}{'yellow_pct'}*100;
        }
        if ($response{$hour}{'red_pct'}) {
                $hour_red_pct = sprintf '%.2f',$response{$hour}{'red_pct'}*100;
        }

	my $hour_standard_out_width  = length($hour_avg) + length($hour_green) + length($hour_yellow) + length($hour_red); 
        my $hour_total_ct_width  = length($hour_ct) + length($hour_green) + length($hour_yellow) + length($hour_red);
        my $hour_total_avg_width  = length($hour_avg) + length($hour_green_avg) + length($hour_yellow_avg) + length($hour_red_avg);
	my $hour_total_pct_width  = length($hour_pct) + length($hour_green_pct) + length($hour_yellow_pct) + length($hour_red_pct);

        if ($hour ne 'day') {

		if ($hour_standard_out_width) {
			if ($options eq "-v") {
				print "$hour     |  $hour_ct ($hour_green,$hour_yellow,$hour_red)";
				print " " x ($total_ct_width - $hour_total_ct_width);
                                print "  |";
                                print "  $hour_avg ($hour_green_avg,$hour_yellow_avg,$hour_red_avg)";
                                print " " x ($total_avg_width - $hour_total_avg_width);
                                print "  |";
				print "  $hour_pct ($hour_green_pct,$hour_yellow_pct,$hour_red_pct)";
				print " " x ($total_pct_width - $hour_total_pct_width);
				print "  |\n";
			} else {
				print "$hour     |  $hour_avg ($hour_green,$hour_yellow,$hour_red)";
				print " " x ($standard_out_width - $hour_standard_out_width);
				print "  |\n";
			}
		}

		if ($options eq "-x") {
			print CSVOUT "$hour:--,$hour_ct,$hour_avg,$hour_pct,,$hour_green,$hour_green_avg,$hour_green_pct,,$hour_yellow,$hour_yellow_avg,$hour_yellow_pct,,$hour_red,$hour_red_avg,$hour_red_pct\n";
		}
	}

	unless ($increment > 59) {
		foreach my $minute (sort keys %{$response{$hour}}) {
			if ( UNIVERSAL::isa($response{$hour}{$minute},'HASH') ) {
			        my $minute_avg = sprintf '%.2f',$response{$hour}{$minute}{'average'};
		       	 	my $minute_ct = $response{$hour}{$minute}{'count'};
			        my $minute_pct = sprintf '%.2f',($response{$hour}{$minute}{'percent'}*100);
				my $minute_green = 0;
			        my $minute_yellow = 0;
			        my $minute_red = 0;
			        my $minute_green_avg = "-";
			        my $minute_yellow_avg = "-";
        			my $minute_red_avg = "-";
				my $minute_green_pct = "-";
				my $minute_yellow_pct = "-";
				my $minute_red_pct = "-";
					
			        if ($response{$hour}{$minute}{'green'}) {
			                $minute_green = $response{$hour}{$minute}{'green'};
			        }
			        if ($response{$hour}{$minute}{'yellow'}) {
			                $minute_yellow = $response{$hour}{$minute}{'yellow'};
			        }
			        if ($response{$hour}{$minute}{'red'}) {
			                $minute_red = $response{$hour}{$minute}{'red'};
			        }
			        if ($response{$hour}{$minute}{'green_avg'}) {
			                $minute_green_avg = sprintf '%.2f',$response{$hour}{$minute}{'green_avg'};
			        }
			        if ($response{$hour}{$minute}{'yellow_avg'}) {
			                $minute_yellow_avg = sprintf '%.2f',$response{$hour}{$minute}{'yellow_avg'};
			        }
			        if ($response{$hour}{$minute}{'red_avg'}) {
			                $minute_red_avg = sprintf '%.2f',$response{$hour}{$minute}{'red_avg'};
			        }
                                if ($response{$hour}{$minute}{'green_pct'}) {
                                        $minute_green_pct = sprintf '%.2f',$response{$hour}{$minute}{'green_pct'}*100;
                                }
                                if ($response{$hour}{$minute}{'yellow_pct'}) {
                                        $minute_yellow_pct = sprintf '%.2f',$response{$hour}{$minute}{'yellow_pct'}*100;
                                }
                                if ($response{$hour}{$minute}{'red_pct'}) {
                                        $minute_red_pct = sprintf '%.2f',$response{$hour}{$minute}{'red_pct'}*100;
                                }

			        my $minute_standard_out_width  = length($minute_avg) + length($minute_green) + length($minute_yellow) + length($minute_red);
			        my $minute_total_ct_width  = length($minute_ct) + length($minute_green) + length($minute_yellow) + length($minute_red);
			        my $minute_total_avg_width  = length($minute_avg) + length($minute_green_avg) + length($minute_yellow_avg) + length($minute_red_avg);
				my $minute_total_pct_width  = length($minute_pct) + length($minute_green_pct) + length($minute_yellow_pct) + length($minute_red_pct);

		                if ($options eq "-v") {
					print "  :$minute  |  $minute_ct ($minute_green,$minute_yellow,$minute_red)";
					print " " x ($total_ct_width - $minute_total_ct_width);
					print "  |";
                                        print "  $minute_avg ($minute_green_avg,$minute_yellow_avg,$minute_red_avg)";
                                        print " " x ($total_avg_width - $minute_total_avg_width);
					print "  |";
					print "  $minute_pct ($minute_green_pct,$minute_yellow_pct,$minute_red_pct)";
					print " " x ($total_pct_width - $minute_total_pct_width);
                                        print "  |\n";
 
				} else {
					print "  :$minute  |  $minute_avg ($minute_green,$minute_yellow,$minute_red)";
		                        print " " x ($standard_out_width - $minute_standard_out_width);
		                        print "  |\n";					
		                }
		
				if ($options eq "-x") {
					print CSVOUT "--:$minute,$minute_ct,$minute_avg,$minute_pct,,$minute_green,$minute_green_avg,$minute_green_pct,,$minute_yellow,$minute_yellow_avg,$minute_yellow_pct,,$minute_red,$minute_red_avg,$minute_red_pct\n";
				}
			}
		}	
	}
}

print "-------+";
if ($options eq "-v") {
        print "-" x ($total_ct_width+9);
        print "+";
        print "-" x ($total_avg_width+9);
	print "+";
	print "-" x ($total_pct_width+9);
	print "+";
} else {
        print "-" x ($standard_out_width+9);
	print "+";
}
print "\n";

if ($options eq "-r") {
        print "Events with over 1 second response output to $oneSecOut\n\n";
        close (REDOUT);
}
if ($options eq "-x") {
        print "Analysis output to $csvOut\n\n";
        close (CSVOUT);
}

print "\nStart analysis: $starttime\n";
print "  End analysis: ".localtime(time)."\n";

close (ELIN);
