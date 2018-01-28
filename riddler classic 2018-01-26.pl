# This area is specific to the map. I labeled the regions of the ostomachion like this:
#
# fEEEEEbbbbbb  
# ffEEEdCbbbbb
# fffEEdCbbbbb
# ffGGddCCbbbb
# ffGGGdCCbbbA
# fGGjjjCCCbAA
# fGGjjjKCCnnn
# fGIjjjKKMMnn
# fGIjjjKKlMnn
# GhIjjjKlllMn
# GhhjjjKlllln
# hhhjjjllllll
#
# starting from mathematical 0 radians (i.e., the center of the right side of the square)
# and working around the edge counterclockwise. Each border between two regions is represented
# by the two regions it separates.

my @name = ('A' .. 'N');
my @area = (3,24,12,6,12,12,12,6,3,21,6,12,6,9);
my @borders = qw(AB AN BC CD CK CM DE DJ EF EG FG GH GI GJ HI IJ JK KL LM MN);

# The border_code array is the borders array translated into binary.
# Example border: CK
#
# nmlKljihgfedCba
# 000100000000100
#
# Therefore, $borders[4] will equal 2**10 + 2**2, or 1028.

my @border_code = ();

for my $c (@borders) {
	push @border_code, make_border_code($c);
}

# The leagues array (I couldn't think of a better name) consists of collections of regions that:
#   1. don't border each other
#   2. have areas that add up to 36
# The entries are the names of the regions that make them up concatenated together in alpahbetical order.

my @leagues = ();

for my $n (0..2**14) {
	next unless test_borders ($n, @border_code); # This will toss out all collections with bordering regions.
	my $sum = 0;
	my $chosen = "";
	for my $x (0..13) { # For each of the regions:
		if ($n & 2**$x) { # If the collection we're looking at contains this region...
			$sum += $area[$x]; # add its area to the running total of this collection
			$chosen .= $name[$x]; # ...and add the name of the region to the collection's name
		}
	}
	push @leagues, $chosen if $sum == 36; # make this collection a league if the sum is 36
}

# Finally, we look at all of the permutations of 4 leagues. If every region is represented exactly once,
# then it represents a proper coloring of the ostomachion.

for ($i = 0; $i < scalar(@leagues) - 3; $i++){
	for ($j = $i + 1; $j < scalar(@leagues) - 2; $j++) {
		for ($k = $j + 1; $k < scalar(@leagues) - 1; $k++) {
			for ($l = $k + 1; $l < scalar(@leagues); $l++) {
				# Smash the names of the leagues together...				
				my $choice = $leagues[$i] . $leagues[$j] . $leagues[$k] . $leagues[$l];
				# ...then sort the name and see if all the regions appear exactly once
				if ((join '', sort { $a cmp $b } split(//, $choice)) eq 'ABCDEFGHIJKLMN') {
					print "$leagues[$i] $leagues[$j] $leagues[$k] $leagues[$l]\n";
				}
			}
		}
	}
}

# This subroutine converts a two-letter pair to a number with two binary bits represented
# by the letters. A = 1, B = 2, C = 3, ... M = 4096, N = 8192.

sub make_border_code {
	my $border = shift;
	return 2**(ord(substr($border, 0, 1)) - ord('A')) + 2**(ord(substr($border, 1, 1)) - ord('A'));
}

# This subroutine takes a collection and a list of borders. It bitwise ANDs the region with all the borders.
# If (collection & border) == border, that means the collection contains the two regions represented by border,
# which means the collection should be rejected.

sub test_borders {
	my $collection = shift;
	while (my $border = shift) {
		if (($collection & $border) == $border) {
			return 0;
		}
	}
	return 1;
}