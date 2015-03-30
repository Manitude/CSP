#!/usr/bin/env perl

sub gInverse {
	local ($num3, $boo, $out);
	local ($t = $_[1]);
	local ($s = $_[0]);
	local @a = split(//,$s);
	local $reserve = $t;
	
	while (@a) {
		$twobits = ($t % 4);
    $t = $t / 4;
    if ($t < 1) { $t = $reserve; }
		for ($i = 0; $i < $twobits; $i++) { shift (@a); }
		$boo = shift(@a);
		$boo .= shift(@a);
		$num3 = $boo + 32;
		$out .= pack("c", $num3);
	}
	
	return "$out";
}

local $x;
$x = &gInverse($ENV{"AICC_ENC_STRING"}, $ENV{"AICC_ENC_KEY"});
print "$x";